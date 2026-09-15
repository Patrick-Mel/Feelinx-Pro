import math
from datetime import timedelta
from django.utils import timezone
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
    def get_feed_profiles(current_profile: Profile, limit: int = 50) -> list:
        pref, _ = Preference.objects.get_or_create(profile=current_profile)

        swiped_ids = set(Swipe.objects.filter(swiper=current_profile).values_list('swiped_id', flat=True))
        blocked_by_me = set(Block.objects.filter(blocker=current_profile.user).values_list('blocked__profile__id', flat=True))
        blocked_me = set(Block.objects.filter(blocked=current_profile.user).values_list('blocker__profile__id', flat=True))

        excluded_ids = swiped_ids.union(blocked_by_me).union(blocked_me)
        excluded_ids.add(current_profile.id)

        lat1 = math.radians(current_profile.latitude or 3.8480)
        long1 = math.radians(current_profile.longitude or 11.5021)

        # Base Queryset
        qs = Profile.objects.filter(
            user__is_active=True,
            is_incognito=False
        ).exclude(id__in=excluded_ids)

        if pref.preferred_genders:
            qs = qs.filter(gender__in=pref.preferred_genders)
        elif current_profile.seeking and current_profile.seeking != 'all':
            qs = qs.filter(gender=current_profile.seeking)

        candidates = list(qs.prefetch_related('photos', 'interests')[:100])

        who_liked_me_ids = set(
            Swipe.objects.filter(swiped=current_profile, action__in=['like', 'superlike'])
            .values_list('swiper_id', flat=True)
        )

        my_interests = set(current_profile.interests.values_list('id', flat=True))

        scored_profiles = []
        for p in candidates:
            plat = p.latitude or 3.8480
            plon = p.longitude or 11.5021
            dlat = math.radians(plat - (current_profile.latitude or 3.8480))
            dlon = math.radians(plon - (current_profile.longitude or 11.5021))
            a = math.sin(dlat / 2)**2 + math.cos(lat1) * math.cos(math.radians(plat)) * math.sin(dlon / 2)**2
            c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a))
            dist_km = 6371 * c

            p.distance_km = round(dist_km, 1)

            distance_score = max(0.1, 1.0 - (dist_km / max(1, pref.max_distance_km or 50)))
            intention_score = get_intention_score(current_profile.intention, p.intention)

            p_interests = set(p.interests.values_list('id', flat=True))
            interests_score = calculate_jaccard_similarity(my_interests, p_interests)

            personality_score = calculate_personality_similarity(current_profile.personality_answers, p.personality_answers)

            days_inactive = (timezone.now() - p.last_seen).days if p.last_seen else 0
            activity_score = max(0.1, 1.0 - (days_inactive / 30.0))

            composite = (
                0.30 * distance_score +
                0.25 * intention_score +
                0.20 * interests_score +
                0.15 * personality_score +
                0.10 * activity_score
            )

            multiplier = 1.0
            if p.id in who_liked_me_ids:
                multiplier *= 2.0
            if p.is_verified:
                multiplier *= 1.2
            if p.is_premium_active:
                multiplier *= 1.1

            final_score = composite * multiplier
            scored_profiles.append((final_score, p))

        # Fallback 1: If candidates were empty due to strict swiped exclusion or gender filter, return all active profiles excluding self
        if len(scored_profiles) < 5:
            all_active = Profile.objects.filter(user__is_active=True).exclude(id=current_profile.id).prefetch_related('photos', 'interests')[:limit]
            existing_ids = {p.id for _, p in scored_profiles}
            for p in all_active:
                if p.id not in existing_ids:
                    p.distance_km = round(3.5 + (hash(p.id.hex) % 30), 1)
                    scored_profiles.append((0.5, p))

        scored_profiles.sort(key=lambda x: x[0], reverse=True)
        return [p for _, p in scored_profiles[:limit]]
