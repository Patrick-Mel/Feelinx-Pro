from datetime import timedelta
from django.utils import timezone
from django.db import transaction
from rest_framework import status, permissions, generics
from rest_framework.views import APIView
from rest_framework.response import Response
from drf_spectacular.utils import extend_schema

from apps.profiles.models import Profile
from apps.profiles.serializers import PublicProfileSerializer
from apps.chat.models import Conversation
from apps.notifications.services import PushNotificationService
from .models import Swipe, Match, Boost
from .serializers import SwipeRequestSerializer, MatchSerializer
from .services.feed import FeedService

class FeedView(APIView):
    permission_classes = [permissions.IsAuthenticated]

    def get(self, request):
        profile = request.user.profile
        limit = int(request.query_params.get('limit', 20))
        profiles = FeedService.get_feed_profiles(profile, limit=limit)
        serializer = PublicProfileSerializer(profiles, many=True, context={'request': request})
        return Response(serializer.data)


class SwipeView(APIView):
    permission_classes = [permissions.IsAuthenticated]

    @extend_schema(
        request=SwipeRequestSerializer,
        responses={200: {"type": "object", "properties": {"is_match": {"type": "boolean"}, "match": {"type": "object"}}}}
    )
    def post(self, request):
        serializer = SwipeRequestSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)

        swiper = request.user.profile
        target_id = serializer.validated_data['target_id']
        action = serializer.validated_data['action']

        try:
            target = Profile.objects.get(id=target_id)
        except Profile.DoesNotExist:
            return Response({"success": False, "message": "Profil cible introuvable."}, status=status.HTTP_404_NOT_FOUND)

        # 1. Enforce free user 30 likes limit per 24 hours
        if not swiper.is_premium_active and action in ['like', 'superlike']:
            recent_likes = Swipe.objects.filter(
                swiper=swiper,
                action__in=['like', 'superlike'],
                created_at__gte=timezone.now() - timedelta(hours=24)
            ).count()

            if recent_likes >= 30:
                return Response(
                    {"success": False, "error_code": "LIKE_LIMIT_REACHED", "message": "Limite de 30 likes atteinte pour aujourd'hui. Passez à Feelinx Premium pour des likes illimités !"},
                    status=status.HTTP_429_TOO_MANY_REQUESTS
                )

        # 2. Record Swipe
        swipe, created = Swipe.objects.update_or_create(
            swiper=swiper,
            swiped=target,
            defaults={'action': action}
        )

        is_match = False
        match_data = None

        # 3. Check for mutual match
        if action in ['like', 'superlike']:
            reciprocal_swipe = Swipe.objects.filter(
                swiper=target,
                swiped=swiper,
                action__in=['like', 'superlike']
            ).first()

            if reciprocal_swipe:
                is_match = True
                with transaction.atomic():
                    p_a, p_b = (swiper, target) if swiper.id < target.id else (target, swiper)
                    match_obj, match_created = Match.objects.get_or_create(
                        profile_a=p_a,
                        profile_b=p_b,
                        defaults={'is_active': True}
                    )
                    if not match_created:
                        match_obj.is_active = True
                        match_obj.save()

                    # Automatically create chat conversation
                    Conversation.objects.get_or_create(match=match_obj)

                match_data = MatchSerializer(match_obj, context={'request': request}).data

                # Send push notification to target user
                PushNotificationService.send_push_to_user(
                    user=target.user,
                    title_fr="Nouveau Match ! 🎉",
                    body_fr=f"Toi et {swiper.first_name} avez matché ! Envoyez-lui un message.",
                    title_en="New Match! 🎉",
                    body_en=f"You and {swiper.first_name} matched! Send a message now.",
                    data={"type": "match", "match_id": str(match_obj.id)}
                )

        return Response({
            "is_match": is_match,
            "match": match_data
        }, status=status.HTTP_200_OK)


class RewindView(APIView):
    permission_classes = [permissions.IsAuthenticated]

    def post(self, request):
        swiper = request.user.profile
        if not swiper.is_premium_active:
            return Response({"success": False, "message": "Option réservée aux membres Feelinx Premium."}, status=status.HTTP_403_FORBIDDEN)

        last_swipe = Swipe.objects.filter(swiper=swiper).order_by('-created_at').first()
        if not last_swipe:
            return Response({"success": False, "message": "Aucun swipe récent à annuler."}, status=status.HTTP_404_NOT_FOUND)

        last_swipe.delete()
        return Response({"success": True, "message": "Dernier swipe annulé avec succès."})


class BoostView(APIView):
    permission_classes = [permissions.IsAuthenticated]

    def post(self, request):
        profile = request.user.profile
        if not profile.is_premium_active:
            return Response({"success": False, "message": "Option réservée aux membres Feelinx Premium."}, status=status.HTTP_403_FORBIDDEN)

        boost = Boost.objects.create(
            profile=profile,
            ends_at=timezone.now() + timedelta(minutes=30)
        )
        return Response({"success": True, "message": "Boost activé pour 30 minutes !", "ends_at": boost.ends_at})


class LikesReceivedView(APIView):
    permission_classes = [permissions.IsAuthenticated]

    def get(self, request):
        profile = request.user.profile
        swipes = Swipe.objects.filter(swiped=profile, action__in=['like', 'superlike']).order_by('-created_at')

        if not profile.is_premium_active:
            # Blurred preview count for non-premium
            return Response({
                "is_premium": False,
                "likes_count": swipes.count(),
                "message": "Passez à Feelinx Premium pour débloquer la liste de tous ceux qui vous ont liké."
            })

        liked_profiles = [s.swiper for s in swipes]
        serializer = PublicProfileSerializer(liked_profiles, many=True, context={'request': request})
        return Response({
            "is_premium": True,
            "likes_count": len(liked_profiles),
            "profiles": serializer.data
        })


class MatchListView(generics.ListAPIView):
    permission_classes = [permissions.IsAuthenticated]
    serializer_class = MatchSerializer

    def get_queryset(self):
        profile = self.request.user.profile
        return Match.objects.filter(
            is_active=True
        ).filter(
            models.Q(profile_a=profile) | models.Q(profile_b=profile)
        ).order_by('-matched_at')


class UnmatchView(APIView):
    permission_classes = [permissions.IsAuthenticated]

    def delete(self, request, match_id):
        profile = request.user.profile
        try:
            match_obj = Match.objects.get(id=match_id)
            if match_obj.profile_a != profile and match_obj.profile_b != profile:
                return Response({"success": False, "message": "Accès refusé."}, status=status.HTTP_403_FORBIDDEN)

            match_obj.is_active = False
            match_obj.unmatched_by = profile
            match_obj.unmatched_at = timezone.now()
            match_obj.save()

            return Response({"success": True, "message": "Match supprimé."})
        except Match.DoesNotExist:
            return Response({"success": False, "message": "Match introuvable."}, status=status.HTTP_404_NOT_FOUND)
