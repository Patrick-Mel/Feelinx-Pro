import random
from datetime import timedelta
from django.utils import timezone
from rest_framework import status, permissions
from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework_simplejwt.tokens import RefreshToken
from drf_spectacular.utils import extend_schema

from .models import User, OTPCode
from .serializers import RequestOTPSerializer, VerifyOTPSerializer, UserSerializer
from .services.sms import get_sms_provider

class RequestOTPView(APIView):
    permission_classes = [permissions.AllowAny]

    @extend_schema(
        request=RequestOTPSerializer,
        responses={200: {"type": "object", "properties": {"success": {"type": "boolean"}, "message": {"type": "string"}, "expires_in": {"type": "integer"}}}}
    )
    def post(self, request):
        serializer = RequestOTPSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        
        phone_number = serializer.validated_data['phone_number']
        
        # Check rate limiting: max 3 requests per hour
        recent_count = OTPCode.objects.filter(
            phone_number=phone_number,
            created_at__gte=timezone.now() - timedelta(hours=1)
        ).count()
        
        if recent_count >= 5:
            return Response(
                {"success": False, "message": "Trop de demandes de code SMS. Veuillez réessayer dans une heure."},
                status=status.HTTP_429_TOO_MANY_REQUESTS
            )

        # Generate 6-digit OTP code
        raw_code = f"{random.randint(100000, 999999)}"
        expires_at = timezone.now() + timedelta(minutes=5)
        
        # Invalidate old unused OTPs
        OTPCode.objects.filter(phone_number=phone_number, is_used=False).update(is_used=True)
        
        otp_obj = OTPCode.objects.create(
            phone_number=phone_number,
            expires_at=expires_at,
            ip_address=request.META.get('REMOTE_ADDR')
        )
        otp_obj.set_code(raw_code)
        otp_obj.save()

        # Send SMS
        sms_provider = get_sms_provider()
        message = f"Ton code de vérification Feelinx est : {raw_code}. Valide pendant 5 minutes."
        sms_sent = sms_provider.send_sms(phone_number, message)

        return Response({
            "success": True,
            "message": "Code de vérification envoyé avec succès.",
            "expires_in": 300
        }, status=status.HTTP_200_OK)


class VerifyOTPView(APIView):
    permission_classes = [permissions.AllowAny]

    @extend_schema(
        request=VerifyOTPSerializer,
        responses={200: {"type": "object", "properties": {"access": {"type": "string"}, "refresh": {"type": "string"}, "is_new_user": {"type": "boolean"}, "has_profile": {"type": "boolean"}}}}
    )
    def post(self, request):
        serializer = VerifyOTPSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)

        phone_number = serializer.validated_data['phone_number']
        raw_code = serializer.validated_data['code']

        # Get latest active OTP
        otp = OTPCode.objects.filter(
            phone_number=phone_number,
            is_used=False
        ).order_by('-created_at').first()

        if not otp or otp.is_expired:
            return Response(
                {"success": False, "message": "Code expiré ou invalide. Demandez un nouveau code."},
                status=status.HTTP_400_BAD_REQUEST
            )

        if otp.attempts >= 5:
            otp.is_used = True
            otp.save()
            return Response(
                {"success": False, "message": "Nombre maximal d'essais dépassé. Demandez un nouveau code."},
                status=status.HTTP_400_BAD_REQUEST
            )

        if not otp.check_code(raw_code):
            otp.attempts += 1
            otp.save()
            return Response(
                {"success": False, "message": "Code incorrect. Veuillez réessayer."},
                status=status.HTTP_400_BAD_REQUEST
            )

        # Mark OTP used
        otp.is_used = True
        otp.save()

        # Get or create User
        user, created = User.objects.get_or_create(phone_number=phone_number)
        if not user.is_phone_verified:
            user.is_phone_verified = True
            user.save()

        # Generate JWT Tokens
        refresh = RefreshToken.for_user(user)
        has_profile = hasattr(user, 'profile') and user.profile is not None

        return Response({
            "access": str(refresh.access_token),
            "refresh": str(refresh),
            "is_new_user": created,
            "has_profile": has_profile,
            "user": UserSerializer(user).data
        }, status=status.HTTP_200_OK)


class LogoutView(APIView):
    permission_classes = [permissions.IsAuthenticated]

    def post(self, request):
        try:
            refresh_token = request.data.get("refresh")
            if refresh_token:
                token = RefreshToken(refresh_token)
                token.blacklist()
            return Response({"success": True, "message": "Déconnexion réussie."}, status=status.HTTP_200_OK)
        except Exception:
            return Response({"success": False, "message": "Token invalide."}, status=status.HTTP_400_BAD_REQUEST)


class DeleteAccountView(APIView):
    permission_classes = [permissions.IsAuthenticated]

    def delete(self, request):
        user = request.user
        user.soft_delete()
        return Response({"success": True, "message": "Compte supprimé avec succès."}, status=status.HTTP_200_OK)
