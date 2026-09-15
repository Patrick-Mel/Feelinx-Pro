import uuid
from django.db import models
from django.contrib.auth.models import AbstractBaseUser, BaseUserManager, PermissionsMixin
from django.utils import timezone
from django.contrib.auth.hashers import make_password, check_password

class UserManager(BaseUserManager):
    def create_user(self, phone_number, password=None, **extra_fields):
        if not phone_number:
            raise ValueError("Le numéro de téléphone est obligatoire.")
        phone_number = self.normalize_phone(phone_number)
        user = self.model(phone_number=phone_number, **extra_fields)
        if password:
            user.set_password(password)
        else:
            user.set_unusable_password()
        user.save(using=self._db)
        return user

    def create_superuser(self, phone_number, password=None, **extra_fields):
        extra_fields.setdefault('is_staff', True)
        extra_fields.setdefault('is_superuser', True)
        extra_fields.setdefault('is_active', True)
        extra_fields.setdefault('is_phone_verified', True)

        if extra_fields.get('is_staff') is not True:
            raise ValueError('Superuser must have is_staff=True.')
        if extra_fields.get('is_superuser') is not True:
            raise ValueError('Superuser must have is_superuser=True.')

        return self.create_user(phone_number, password, **extra_fields)

    def normalize_phone(self, phone_number):
        """Clean whitespace and validate international E.164 phone format."""
        if not phone_number:
            raise ValueError("Le numéro de téléphone est obligatoire.")
        phone = str(phone_number).strip().replace(" ", "").replace("-", "")
        if not phone.startswith("+"):
            if phone.startswith("237"):
                phone = "+" + phone
            elif len(phone) == 9:
                phone = "+237" + phone

        import re
        if not re.match(r'^\+[1-9]\d{8,14}$', phone):
            raise ValueError("Numéro de téléphone invalide. Veuillez entrer un numéro au format international (ex: +237690000000).")

        digits = phone.lstrip('+')
        if len(digits) >= 6 and len(set(digits[3:])) == 1:
            raise ValueError("Numéro de téléphone invalide. Les numéros fictifs répétitifs ne sont pas autorisés.")

        return phone


class User(AbstractBaseUser, PermissionsMixin):
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    phone_number = models.CharField(max_length=20, unique=True, db_index=True)
    is_phone_verified = models.BooleanField(default=False)
    is_active = models.BooleanField(default=True)
    is_staff = models.BooleanField(default=False)
    date_joined = models.DateTimeField(default=timezone.now)
    last_active_at = models.DateTimeField(auto_now=True)
    language = models.CharField(max_length=5, choices=[('fr', 'Français'), ('en', 'English')], default='fr')
    deleted_at = models.DateTimeField(null=True, blank=True)

    objects = UserManager()

    USERNAME_FIELD = 'phone_number'
    REQUIRED_FIELDS = []

    class Meta:
        verbose_name = "Utilisateur"
        verbose_name_plural = "Utilisateurs"
        ordering = ['-date_joined']

    def __str__(self):
        return self.phone_number

    def soft_delete(self):
        self.is_active = False
        self.deleted_at = timezone.now()
        self.save()


class OTPCode(models.Model):
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    phone_number = models.CharField(max_length=20, db_index=True)
    code_hash = models.CharField(max_length=255)
    purpose = models.CharField(max_length=20, default='login')
    expires_at = models.DateTimeField()
    attempts = models.PositiveIntegerField(default=0)
    is_used = models.BooleanField(default=False)
    created_at = models.DateTimeField(auto_now_add=True)
    ip_address = models.GenericIPAddressField(null=True, blank=True)

    class Meta:
        verbose_name = "Code OTP"
        verbose_name_plural = "Codes OTP"
        ordering = ['-created_at']

    def set_code(self, raw_code):
        self.code_hash = make_password(raw_code)

    def check_code(self, raw_code):
        return check_password(raw_code, self.code_hash)

    @property
    def is_expired(self):
        return timezone.now() > self.expires_at
