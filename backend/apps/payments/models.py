import uuid
from django.db import models
from django.utils import timezone
from apps.profiles.models import Profile

PROVIDER_CHOICES = [
    ('mtn', 'MTN Mobile Money'),
    ('orange', 'Orange Money'),
    ('mock', 'Mode Test / Demo'),
]

STATUS_CHOICES = [
    ('pending', 'En attente de validation USSD'),
    ('success', 'Succès'),
    ('failed', 'Échec'),
    ('cancelled', 'Annulé'),
]

class Plan(models.Model):
    code = models.CharField(max_length=50, primary_key=True) # e.g. 'premium_1m', 'premium_3m', 'premium_12m'
    name_fr = models.CharField(max_length=100)
    name_en = models.CharField(max_length=100)
    duration_days = models.PositiveIntegerField(default=30)
    price_xaf = models.PositiveIntegerField(help_text="Prix en FCFA (XAF)")
    is_active = models.BooleanField(default=True)
    is_popular = models.BooleanField(default=False)

    class Meta:
        verbose_name = "Formule d'abonnement"
        verbose_name_plural = "Formules d'abonnement"
        ordering = ['price_xaf']

    def __str__(self):
        return f"{self.name_fr} ({self.price_xaf:,} FCFA)"


class Subscription(models.Model):
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    profile = models.ForeignKey(Profile, on_delete=models.CASCADE, related_name='subscriptions')
    plan = models.ForeignKey(Plan, on_delete=models.PROTECT)
    started_at = models.DateTimeField(default=timezone.now)
    expires_at = models.DateTimeField()
    status = models.CharField(max_length=20, default='active')
    auto_renew = models.BooleanField(default=False)

    class Meta:
        ordering = ['-started_at']

    def __str__(self):
        return f"Abonnement {self.plan.name_fr} - {self.profile.first_name}"


class Transaction(models.Model):
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    profile = models.ForeignKey(Profile, on_delete=models.CASCADE, related_name='transactions')
    plan = models.ForeignKey(Plan, on_delete=models.PROTECT)
    amount_xaf = models.PositiveIntegerField()
    provider = models.CharField(max_length=10, choices=PROVIDER_CHOICES)
    provider_reference = models.CharField(max_length=255, blank=True, null=True, db_index=True)
    phone_number = models.CharField(max_length=20)
    status = models.CharField(max_length=20, choices=STATUS_CHOICES, default='pending')
    raw_response = models.JSONField(default=dict, blank=True)
    created_at = models.DateTimeField(auto_now_add=True)
    completed_at = models.DateTimeField(null=True, blank=True)

    class Meta:
        ordering = ['-created_at']

    def __str__(self):
        return f"Transaction {self.id} ({self.amount_xaf} XAF) - {self.status}"
