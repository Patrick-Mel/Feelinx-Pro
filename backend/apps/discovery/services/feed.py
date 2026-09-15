import math
from datetime import timedelta
from django.utils import timezone
from django.db.models import F, Q, FloatField, ExpressionWrapper
from django.db.models.functions import ACos, Cos, Radians, Sin
from apps.profiles.models import Profile, Preference
from apps.discovery.models import Swipe, Boost
from apps.safety.models import Block

INTENTION_COMPATIBILITY_MATRIX = {
    ('serious', 'serious'): 1.0,
    ('serious', 'casual'): 0.5,
    ('serious', 'undecided'): 0.7,
    ('casual', 'casual'): 1.0,
    ('friendship', 'friendship'): 1.0,
    ('networking', 'networking'): 1.0,
}

def get_intention_score(intent1: str, intent2: str) -> float:
    if intent1 == intent2:
        return 1.0
    pair = (intent1, intent2)
    rev_pair = (intent2, intent1)
    return INTENTION_COMPATIBILITY_MATRIX.get(pair, INTENTION_COMPATIBILITY_MATRIX.get(rev_pair, 0.3))


def calculate_jaccard_similarity(set1: set, set2: set) -> float:
    if not set1 or not set2:
        return 0.0
    intersection = len(set1.intersection(set2))
    union = len(set1.union(set2))
    return intersection / union if union > 0 else 0.0


def calculate_personality_similarity(answers1: dict, answers2: dict) -> float:
    if not answers1 or not answers2:
        return 0.5
    keys = set(answers1.keys()).intersection(set(answers2.keys()))
    if not keys:
        return 0.5
    matches = sum(1 for k in keys if answers1[k] == answers2[k])
    return matches / len(keys)


class FeedService:
    @staticmethod
    def get_feed_profiles(current_profile: Profile, limit: int = 20) -> list:
        # Get user preferences or fallback default
        pref, _ = Preference.objects.get_or_create(profile=current_profile)

        # 1. Exclude self, already swiped, blocked, inactive
        swiped_ids = Swipe.objects.filter(swiper=current_profile).values_list('swiped_id', flat=True)
        blocked_by_me = Block.objects.filter(blocker=current_profile.user).values_list('blocked__profile__id', flat=True)
        blocked_me = Block.objects.filter(blocked=current_profile.user).values_list('blocker__profile__id', flat=True)

        excluded_ids = set(swiped_ids).union(set(blocked_by_me)).union(set(blocked_me))
        excluded_ids.add(current_profile.id)

        # Haversine SQL formula for distance in kilometers
        lat1 = math.radians(current_profile.latitude)
        long1 = math.radians(current_profile.longitude)

        # Base Queryset
        qs = Profile.objects.filter(
            user__is_active=True,
            is_incognito=False
        ).exclude(id__in=excluded_ids)

        # Gender preference filter
        if pref.preferred_genders:
            qs = qs.filter(gender__in=pref.preferred_genders)

        # Intention preference filter
        if pref.preferred_intentions:
            qs = qs.filter(intention__in=pref.preferred_intentions)

        # Verified only filter
        if pref.verified_only:
            qs = qs.filter(is_verified=True)

        candidates = list(qs.prefetch_related('photos', 'interests')[:100])

        # Pre-fetch profiles who have already liked current_profile (to give 2.0x match boost)
        who_liked_me_ids = set(
            Swipe.objects.filter(swiped=current_profile, action__in=['like', 'superlike'])
            .values_list('swiper_id', flat=True)
        )

        my_interests = set(current_profile.interests.values_list('id', flat=True))

        scored_profiles = []
        for p in candidates:
            # Check age boundary
            if not (pref.min_age <= p.age <= pref.max_age):
                continue

            # Calculate Haversine distance in Python (accurate & simple)
            dlat = math.radians(p.latitude - current_profile.latitude)
            dlon = math.radians(p.longitude - current_profile.longitude)
            a = math.sin(dlat / 2)**2 + math.cos(lat1) * math.cos(math.radians(p.latitude)) * math.sin(dlon / 2)**2
            c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a))
            dist_km = 6371 * c

            if dist_km > pref.max_distance_km:
                continue

            p.distance_km = round(dist_km, 1)

            # Score components
            distance_score = max(0.1, 1.0 - (dist_km / max(1, pref.max_distance_km)))
            intention_score = get_intention_score(current_profile.intention, p.intention)

            p_interests = set(p.interests.values_list('id', flat=True))
            interests_score = calculate_jaccard_similarity(my_interests, p_interests)

            personality_score = calculate_personality_similarity(current_profile.personality_answers, p.personality_answers)

            days_inactive = (timezone.now() - p.last_seen).days
            activity_score = max(0.1, 1.0 - (days_inactive / 30.0))

            # Composite base score
            composite = (
                0.30 * distance_score +
                0.25 * intention_score +
                0.20 * interests_score +
                0.15 * personality_score +
                0.10 * activity_score
            )

            # Modifiers
            multiplier = 1.0
            if p.id in who_liked_me_ids:
                multiplier *= 2.0 # Has liked current user -> priority!
            if p.is_verified:
                multiplier *= 1.2
            if p.is_premium_active:
                multiplier *= 1.1
            if (timezone.now() - p.created_at).total_seconds() < 172800: # < 48 hours
                multiplier *= 1.5
            
            # Active boost check
            if Boost.objects.filter(profile=p, ends_at__gt=timezone.now()).exists():
                multiplier *= 3.0

            final_score = composite * multiplier
            scored_profiles.append((final_score, p))

        # Sort by final score descending
        scored_profiles.sort(key=lambda x: x[0], reverse=True)
        return [p for _, p in scored_profiles[:limit]]
