from rest_framework import status, permissions, generics
from rest_framework.views import APIView
from rest_framework.response import Response
from apps.accounts.models import User
from .models import Verification, Report, Block
from .serializers import VerificationSerializer, ReportSerializer, BlockSerializer

class VerificationUploadView(APIView):
    permission_classes = [permissions.IsAuthenticated]

    def post(self, request):
        profile = request.user.profile
        file_obj = request.FILES.get('selfie')

        if not file_obj:
            return Response({"success": False, "message": "Selfie obligatoire pour la vérification."}, status=status.HTTP_400_BAD_REQUEST)

        # In dev mode auto approve selfie verification
        v = Verification.objects.create(
            profile=profile,
            selfie=file_obj,
            requested_pose='peace_sign',
            status='approved'
        )

        profile.is_verified = True
        profile.verification_status = 'approved'
        profile.save()

        return Response(VerificationSerializer(v, context={'request': request}).data, status=status.HTTP_201_CREATED)


class VerificationStatusView(APIView):
    permission_classes = [permissions.IsAuthenticated]

    def get(self, request):
        v = Verification.objects.filter(profile=request.user.profile).order_by('-created_at').first()
        if not v:
            return Response({"is_verified": request.user.profile.is_verified, "verification": None})
        return Response({"is_verified": request.user.profile.is_verified, "verification": VerificationSerializer(v, context={'request': request}).data})


class ReportCreateView(APIView):
    permission_classes = [permissions.IsAuthenticated]

    def post(self, request):
        serializer = ReportSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        report = serializer.save(reporter=request.user.profile)

        # Automatic check: if target reported 3+ times, flag account for review
        report_count = Report.objects.filter(reported=report.reported).count()
        if report_count >= 3:
            report.reported.user.is_active = False # Suspend profile for moderation review
            report.reported.user.save()

        return Response({"success": True, "message": "Signalement transmis à notre équipe de modération. Merci."}, status=status.HTTP_201_CREATED)


class BlockListCreateView(APIView):
    permission_classes = [permissions.IsAuthenticated]

    def get(self, request):
        blocks = Block.objects.filter(blocker=request.user)
        serializer = BlockSerializer(blocks, many=True, context={'request': request})
        return Response(serializer.data)

    def post(self, request):
        blocked_user_id = request.data.get('blocked_user_id')
        try:
            target_user = User.objects.get(id=blocked_user_id)
            block, created = Block.objects.get_or_create(blocker=request.user, blocked=target_user)
            
            # Deactivate any active match & conversation immediately
            from apps.discovery.models import Match
            Match.objects.filter(
                models.Q(profile_a=request.user.profile, profile_b=target_user.profile) |
                models.Q(profile_a=target_user.profile, profile_b=request.user.profile)
            ).update(is_active=False)

            return Response(BlockSerializer(block, context={'request': request}).data, status=status.HTTP_201_CREATED)
        except User.DoesNotExist:
            return Response({"success": False, "message": "Utilisateur introuvable."}, status=status.HTTP_404_NOT_FOUND)


class UnblockView(APIView):
    permission_classes = [permissions.IsAuthenticated]

    def delete(self, request, block_id):
        try:
            block = Block.objects.get(id=block_id, blocker=request.user)
            block.delete()
            return Response({"success": True, "message": "Déblocage effectué."})
        except Block.DoesNotExist:
            return Response({"success": False, "message": "Blocage introuvable."}, status=status.HTTP_404_NOT_FOUND)
