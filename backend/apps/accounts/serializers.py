from rest_framework import serializers
from .models import User

class RequestOTPSerializer(serializers.Serializer):
    phone_number = serializers.CharField(max_length=20)

    def validate_phone_number(self, value):
        from .models import User
        try:
            return User.objects.normalize_phone(value)
        except ValueError as e:
            raise serializers.ValidationError(str(e))


class VerifyOTPSerializer(serializers.Serializer):
    phone_number = serializers.CharField(max_length=20)
    code = serializers.CharField(min_length=6, max_length=6)

    def validate_phone_number(self, value):
        from .models import User
        try:
            return User.objects.normalize_phone(value)
        except ValueError as e:
            raise serializers.ValidationError(str(e))


class PasswordLoginSerializer(serializers.Serializer):
    phone_number = serializers.CharField(max_length=20)
    password = serializers.CharField(min_length=6, max_length=128, write_only=True)

    def validate_phone_number(self, value):
        from .models import User
        try:
            return User.objects.normalize_phone(value)
        except ValueError as e:
            raise serializers.ValidationError(str(e))


class RegisterWithPasswordSerializer(serializers.Serializer):
    phone_number = serializers.CharField(max_length=20)
    password = serializers.CharField(min_length=6, max_length=128, write_only=True)

    def validate_phone_number(self, value):
        from .models import User
        try:
            return User.objects.normalize_phone(value)
        except ValueError as e:
            raise serializers.ValidationError(str(e))


class ResetPasswordConfirmSerializer(serializers.Serializer):
    phone_number = serializers.CharField(max_length=20)
    code = serializers.CharField(min_length=6, max_length=6)
    new_password = serializers.CharField(min_length=6, max_length=128, write_only=True)

    def validate_phone_number(self, value):
        from .models import User
        try:
            return User.objects.normalize_phone(value)
        except ValueError as e:
            raise serializers.ValidationError(str(e))


class UserSerializer(serializers.ModelSerializer):
    has_profile = serializers.SerializerMethodField()

    class Meta:
        model = User
        fields = ['id', 'phone_number', 'is_phone_verified', 'language', 'date_joined', 'has_profile']
        read_only_fields = ['id', 'is_phone_verified', 'date_joined', 'has_profile']

    def get_has_profile(self, obj):
        return hasattr(obj, 'profile') and obj.profile is not None
