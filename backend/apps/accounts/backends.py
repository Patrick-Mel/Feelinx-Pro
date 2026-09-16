from django.contrib.auth.backends import ModelBackend
from django.contrib.auth import get_user_model

class PhoneBackend(ModelBackend):
    def authenticate(self, request, username=None, password=None, **kwargs):
        phone_number = username or kwargs.get('phone_number')
        if not phone_number or not password:
            return None

        User = get_user_model()
        user = None
        phone_clean = str(phone_number).strip().replace(' ', '').replace('-', '')

        # 1. Exact match
        user = User.objects.filter(phone_number=phone_clean).first()

        # 2. Try with leading '+'
        if not user and not phone_clean.startswith('+'):
            user = User.objects.filter(phone_number='+' + phone_clean).first()

        # 3. Normalized phone lookup
        if not user and hasattr(User.objects, 'normalize_phone'):
            try:
                normalized = User.objects.normalize_phone(phone_number)
                user = User.objects.filter(phone_number=normalized).first()
            except Exception:
                pass

        # 4. Flexible suffix match (matches 689731055 inside +237689731055)
        if not user:
            digits = ''.join(c for c in phone_clean if c.isdigit())
            if len(digits) >= 8:
                user = User.objects.filter(phone_number__icontains=digits[-8:]).first()

        if user and user.check_password(password) and self.user_can_authenticate(user):
            return user

        return None
