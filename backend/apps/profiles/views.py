import io
from PIL import Image, ImageOps
from django.core.files.base import ContentFile
from rest_framework import status, permissions, generics
from rest_framework.views import APIView
from rest_framework.response import Response
from drf_spectacular.utils import extend_schema

from .models import Profile, Photo, Interest, Preference
from .serializers import (
    ProfileSerializer, PublicProfileSerializer, PhotoSerializer,
    PreferenceSerializer, InterestSerializer
)

class MyProfileView(APIView):
    permission_classes = [permissions.IsAuthenticated]

    def get(self, request):
        profile, created = Profile.objects.get_or_create(
            user=request.user,
            defaults={
                'first_name': 'Membre',
                'birth_date': '2000-01-01',
                'gender': 'male',
            }
        )
        if created or not hasattr(profile, 'preference'):
            Preference.objects.get_or_create(profile=profile)

        serializer = ProfileSerializer(profile, context={'request': request})
        return Response(serializer.data)

    def patch(self, request):
        profile, _ = Profile.objects.get_or_create(user=request.user)
        serializer = ProfileSerializer(profile, data=request.data, partial=True, context={'request': request})
        serializer.is_valid(raise_exception=True)
        serializer.save()
        return Response(serializer.data)


class PhotoUploadView(APIView):
    permission_classes = [permissions.IsAuthenticated]

    def post(self, request):
        profile = request.user.profile
        file_obj = request.FILES.get('image')

        if not file_obj:
            return Response({"success": False, "message": "Aucun fichier d'image fourni."}, status=status.HTTP_400_BAD_REQUEST)

        if profile.photos.count() >= 9:
            return Response({"success": False, "message": "Maximum 9 photos autorisées."}, status=status.HTTP_400_BAD_REQUEST)

        try:
            # Open image with Pillow, strip EXIF metadata
            img = Image.open(file_obj)
            img = ImageOps.exif_transpose(img) # auto orient
            img = img.convert('RGB')

            # Compress main image (max 1200x1200)
            img.thumbnail((1200, 1200), Image.Resampling.LANCZOS)
            output = io.BytesIO()
            img.save(output, format='JPEG', quality=85, optimize=True)
            output.seek(0)
            compressed_file = ContentFile(output.read(), name=f"photo_{profile.id}_{file_obj.name}.jpg")

            # Generate thumbnail (max 400x400)
            thumb = img.copy()
            thumb.thumbnail((400, 400), Image.Resampling.LANCZOS)
            thumb_output = io.BytesIO()
            thumb.save(thumb_output, format='JPEG', quality=75, optimize=True)
            thumb_output.seek(0)
            thumb_file = ContentFile(thumb_output.read(), name=f"thumb_{profile.id}_{file_obj.name}.jpg")

            order = profile.photos.count()
            is_primary = (order == 0)

            photo = Photo.objects.create(
                profile=profile,
                image=compressed_file,
                thumbnail=thumb_file,
                order=order,
                is_primary=is_primary
            )

            serializer = PhotoSerializer(photo, context={'request': request})
            return Response(serializer.data, status=status.HTTP_201_CREATED)

        except Exception as e:
            return Response({"success": False, "message": f"Erreur de traitement d'image: {str(e)}"}, status=status.HTTP_400_BAD_REQUEST)


class PhotoDetailView(APIView):
    permission_classes = [permissions.IsAuthenticated]

    def delete(self, request, photo_id):
        profile = request.user.profile
        try:
            photo = Photo.objects.get(id=photo_id, profile=profile)
            photo.delete()
            
            # Reorder remaining photos
            for idx, p in enumerate(profile.photos.all()):
                p.order = idx
                if idx == 0:
                    p.is_primary = True
                p.save()

            return Response({"success": True, "message": "Photo supprimée."}, status=status.HTTP_200_OK)
        except Photo.DoesNotExist:
            return Response({"success": False, "message": "Photo introuvable."}, status=status.HTTP_404_NOT_FOUND)


class PhotoReorderView(APIView):
    permission_classes = [permissions.IsAuthenticated]

    def patch(self, request):
        profile = request.user.profile
        order_ids = request.data.get('order', []) # list of photo UUID strings

        for idx, photo_id in enumerate(order_ids):
            Photo.objects.filter(id=photo_id, profile=profile).update(
                order=idx,
                is_primary=(idx == 0)
            )

        photos = profile.photos.all()
        serializer = PhotoSerializer(photos, many=True, context={'request': request})
        return Response(serializer.data)


class PreferenceView(APIView):
    permission_classes = [permissions.IsAuthenticated]

    def get(self, request):
        pref, _ = Preference.objects.get_or_create(profile=request.user.profile)
        serializer = PreferenceSerializer(pref)
        return Response(serializer.data)

    def patch(self, request):
        pref, _ = Preference.objects.get_or_create(profile=request.user.profile)
        serializer = PreferenceSerializer(pref, data=request.data, partial=True)
        serializer.is_valid(raise_exception=True)
        serializer.save()
        return Response(serializer.data)


class PersonalityQuizView(APIView):
    permission_classes = [permissions.IsAuthenticated]

    def post(self, request):
        profile = request.user.profile
        answers = request.data.get('answers', {})
        profile.personality_answers = answers
        profile.save()
        return Response({"success": True, "message": "Réponses enregistrées avec succès.", "answers": profile.personality_answers})


class ProfileStatsView(APIView):
    permission_classes = [permissions.IsAuthenticated]

    def get(self, request):
        from apps.discovery.models import Swipe, Match, ProfileView
        profile = request.user.profile

        views_count = ProfileView.objects.filter(viewed=profile).count()
        likes_received_count = Swipe.objects.filter(swiped=profile, action__in=['like', 'superlike']).count()
        matches_count = Match.objects.filter(profile_a=profile, is_active=True).count() + Match.objects.filter(profile_b=profile, is_active=True).count()

        return Response({
            "views_count": views_count,
            "likes_received_count": likes_received_count,
            "matches_count": matches_count,
            "is_premium": profile.is_premium_active
        })


class PublicProfileDetailView(APIView):
    permission_classes = [permissions.IsAuthenticated]

    def get(self, request, profile_id):
        try:
            profile = Profile.objects.get(id=profile_id)
            serializer = PublicProfileSerializer(profile, context={'request': request})
            return Response(serializer.data)
        except Profile.DoesNotExist:
            return Response({"success": False, "message": "Profil introuvable."}, status=status.HTTP_404_NOT_FOUND)


class InterestListView(generics.ListAPIView):
    permission_classes = [permissions.AllowAny]
    queryset = Interest.objects.all()
    serializer_class = InterestSerializer
    pagination_class = None


class VerifyProfileView(APIView):
    permission_classes = [permissions.IsAuthenticated]

    def post(self, request):
        profile = request.user.profile
        profile.is_verified = True
        profile.save()
        return Response({
            "success": True,
            "message": "Félicitations, ton profil a été vérifié avec succès ! 🛡️",
            "is_verified": True
        })

