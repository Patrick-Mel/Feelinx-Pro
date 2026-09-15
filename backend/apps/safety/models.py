import uuid
from django.db import models
from django.conf import settings
from apps.profiles.models import Profile

REPORT_REASON_CHOICES = [
    ('fake_profile', 'Faux profil / usurpation'),
    ('financial_scam', 'Demande d\'argent / arnaque'),
    ('harassment', 'Harcèlement / propos injurieux'),
    ('inappropriate_content', 'Contenu explicite / inapproprié'),
    ('underage', 'Mineur'),
    ('other', 'Autre'),
]

VERIFICATION_STATUS_CHOICES = [
    ('pending', 'En attente de revue'),
    ('approved', 'Approuvé'),
    ('rejected', 'Rejeté'),
]

class Verification(models.Model):
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    profile = models.ForeignKey(Profile, on_delete=models.CASCADE, related_name='verifications')
    selfie = models.ImageField(upload_to='verifications/selfies/')
    requested_pose = models.CharField(max_length=50, default='peace_sign')
    status = models.CharField(max_length=20, choices=VERIFICATION_STATUS_CHOICES, default='pending')
    reviewed_at = models.DateTimeField(null=True, blank=True)
    rejection_reason = models.TextField(blank=True)
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        ordering = ['-created_at']

    def __str__(self):
        return f"Vérification de {self.profile.first_name} ({self.status})"


class Report(models.Model):
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    reporter = models.ForeignKey(Profile, on_delete=models.CASCADE, related_name='reports_sent')
    reported = models.ForeignKey(Profile, on_delete=models.CASCADE, related_name='reports_received')
    reason = models.CharField(max_length=30, choices=REPORT_REASON_CHOICES)
    description = models.TextField(blank=True)
    evidence_message = models.TextField(blank=True)
    status = models.CharField(max_length=20, default='pending')
    created_at = models.DateTimeField(auto_now_add=True)
    reviewed_at = models.DateTimeField(null=True, blank=True)
    action_taken = models.CharField(max_length=100, blank=True)

    class Meta:
        ordering = ['-created_at']

    def __str__(self):
        return f"Signalement: {self.reporter.first_name} -> {self.reported.first_name} ({self.reason})"


class Block(models.Model):
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    blocker = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=models.CASCADE, related_name='blocks_initiated')
    blocked = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=models.CASCADE, related_name='blocks_received')
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        unique_together = ('blocker', 'blocked')
        ordering = ['-created_at']

    def __str__(self):
        return f"Blocage: {self.blocker} -> {self.blocked}"
