from django.contrib.auth.backends import ModelBackend
from django.contrib.auth import get_user_model

class PhoneBackend(ModelBackend):
    def authenticate(self, request, username=None, password=None, **kwargs):
        phone_number = username or kwargs.get('phone_number')
        if not phone_number or not password:
            return None

        User = get_user_model()
        user = None

        # 1. Try exact match
        user = User.objects.filter(phone_number=phone_number).first()

        # 2. Try normalized phone number
        if not user and hasattr(User.objects, 'normalize_phone'):
            try:
                normalized_phone = User.objects.normalize_phone(phone_number)
                user = User.objects.filter(phone_number=normalized_phone).first()
            except Exception:
                pass

        # 3. Try fallback match by trailing digits (for +237 / local variants)
        if not user:
            clean_digits = ''.join(c for c in phone_number if c.isdigit())
            if len(clean_digits) >= 8:
                user = User.objects.filter(phone_number__endswith=clean_digits[-8:]).first()

        if user and user.check_password(password) and self.user_can_authenticate(user):
            return user

        return None
