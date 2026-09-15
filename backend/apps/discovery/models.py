import uuid
from django.db import models
from django.utils import timezone
from apps.profiles.models import Profile

ACTION_CHOICES = [
    ('like', 'Like'),
    ('nope', 'Nope'),
    ('superlike', 'Super Like'),
]

class Swipe(models.Model):
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    swiper = models.ForeignKey(Profile, on_delete=models.CASCADE, related_name='swipes_made')
    swiped = models.ForeignKey(Profile, on_delete=models.CASCADE, related_name='swipes_received')
    action = models.CharField(max_length=10, choices=ACTION_CHOICES)
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        verbose_name = "Swipe"
        verbose_name_plural = "Swipes"
        unique_together = ('swiper', 'swiped')
        ordering = ['-created_at']

    def __str__(self):
        return f"{self.swiper.first_name} -> {self.action} -> {self.swiped.first_name}"


class Match(models.Model):
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    profile_a = models.ForeignKey(Profile, on_delete=models.CASCADE, related_name='matches_as_a')
    profile_b = models.ForeignKey(Profile, on_delete=models.CASCADE, related_name='matches_as_b')
    matched_at = models.DateTimeField(auto_now_add=True)
    is_active = models.BooleanField(default=True)
    unmatched_by = models.ForeignKey(Profile, on_delete=models.SET_NULL, null=True, blank=True, related_name='unmatches_initiated')
    unmatched_at = models.DateTimeField(null=True, blank=True)

    class Meta:
        verbose_name = "Match"
        verbose_name_plural = "Matchs"
        unique_together = ('profile_a', 'profile_b')
        ordering = ['-matched_at']

    def __str__(self):
        return f"Match: {self.profile_a.first_name} ❤️ {self.profile_b.first_name}"

    def save(self, *args, **kwargs):
        # Guarantee profile_a UUID is smaller than profile_b UUID for canonical ordering
        if self.profile_a.id > self.profile_b.id:
            self.profile_a, self.profile_b = self.profile_b, self.profile_a
        super().save(*args, **kwargs)


class ProfileView(models.Model):
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    viewer = models.ForeignKey(Profile, on_delete=models.CASCADE, related_name='views_made')
    viewed = models.ForeignKey(Profile, on_delete=models.CASCADE, related_name='views_received')
    viewed_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        ordering = ['-viewed_at']


class Boost(models.Model):
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    profile = models.ForeignKey(Profile, on_delete=models.CASCADE, related_name='boosts')
    started_at = models.DateTimeField(auto_now_add=True)
    ends_at = models.DateTimeField()
    views_gained = models.PositiveIntegerField(default=0)

    class Meta:
        ordering = ['-started_at']

    @property
    def is_active(self):
        return timezone.now() < self.ends_at
