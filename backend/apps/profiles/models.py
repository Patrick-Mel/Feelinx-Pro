import uuid
from datetime import date
from django.db import models
from django.conf import settings
from django.utils import timezone

INTENTION_CHOICES = [
    ('serious', 'Relation sérieuse'),
    ('casual', 'Rencontre décontractée'),
    ('friendship', 'Amitié'),
    ('networking', 'Réseautage professionnel'),
    ('undecided', 'Je ne sais pas encore'),
]

GENDER_CHOICES = [
    ('male', 'Homme'),
    ('female', 'Femme'),
    ('other', 'Autre'),
]

class Interest(models.Model):
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    code = models.CharField(max_length=50, unique=True)
    name_fr = models.CharField(max_length=100)
    name_en = models.CharField(max_length=100)
    emoji = models.CharField(max_length=10)
    category = models.CharField(max_length=50, default='lifestyle')

    class Meta:
        verbose_name = "Centre d'intérêt"
        verbose_name_plural = "Centres d'intérêt"
        ordering = ['name_fr']

    def __str__(self):
        return f"{self.emoji} {self.name_fr}"


class Profile(models.Model):
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    user = models.OneToOneField(settings.AUTH_USER_MODEL, on_delete=models.CASCADE, related_name='profile')
    first_name = models.CharField(max_length=50)
    last_name = models.CharField(max_length=50, blank=True, default='')
    birth_date = models.DateField()
    gender = models.CharField(max_length=10, choices=GENDER_CHOICES)
    seeking = models.CharField(max_length=10, choices=GENDER_CHOICES, default='female')
    intention = models.CharField(max_length=20, choices=INTENTION_CHOICES, default='serious')
    bio = models.TextField(max_length=500, blank=True)
    city = models.CharField(max_length=100, default='Yaoundé')
    neighborhood = models.CharField(max_length=100, blank=True)
    latitude = models.FloatField(default=3.8480) # Default Yaoundé coords
    longitude = models.FloatField(default=11.5021)
    
    is_verified = models.BooleanField(default=False)
    verification_status = models.CharField(max_length=20, default='none') # none, pending, approved, rejected
    
    is_premium = models.BooleanField(default=False)
    premium_until = models.DateTimeField(null=True, blank=True)
    
    is_incognito = models.BooleanField(default=False)
    hide_distance = models.BooleanField(default=False)
    hide_age = models.BooleanField(default=False)
    
    personality_answers = models.JSONField(default=dict, blank=True)
    last_seen = models.DateTimeField(default=timezone.now)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    interests = models.ManyToManyField(Interest, through='ProfileInterest', related_name='profiles')

    class Meta:
        verbose_name = "Profil"
        verbose_name_plural = "Profils"
        indexes = [
            models.Index(fields=['latitude', 'longitude']),
            models.Index(fields=['gender']),
            models.Index(fields=['intention']),
            models.Index(fields=['is_premium']),
        ]

    def __str__(self):
        return f"{self.first_name} ({self.age} ans) - {self.city}"

    @property
    def full_name(self):
        if self.last_name:
            return f"{self.first_name} {self.last_name}"
        return self.first_name

    @property
    def age(self):
        if not self.birth_date:
            return 18
        today = date.today()
        return today.year - self.birth_date.year - ((today.month, today.day) < (self.birth_date.month, self.birth_date.day))

    @property
    def is_premium_active(self):
        if not self.is_premium:
            return False
        if self.premium_until and self.premium_until < timezone.now():
            return False
        return True

    @property
    def profile_completion(self):
        score = 0
        if self.first_name: score += 15
        if self.birth_date: score += 15
        if self.bio: score += 15
        if self.photos.filter(is_approved=True).count() >= 2: score += 35
        elif self.photos.exists(): score += 15
        if self.interests.exists(): score += 10
        if self.personality_answers: score += 10
        return min(100, score)


class ProfileInterest(models.Model):
    profile = models.ForeignKey(Profile, on_delete=models.CASCADE)
    interest = models.ForeignKey(Interest, on_delete=models.CASCADE)

    class Meta:
        unique_together = ('profile', 'interest')


class Photo(models.Model):
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    profile = models.ForeignKey(Profile, on_delete=models.CASCADE, related_name='photos')
    image = models.ImageField(upload_to='profiles/photos/')
    thumbnail = models.ImageField(upload_to='profiles/thumbnails/', null=True, blank=True)
    order = models.PositiveSmallIntegerField(default=0)
    is_primary = models.BooleanField(default=False)
    is_approved = models.BooleanField(default=True) # Auto approve in dev
    uploaded_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        ordering = ['order', 'uploaded_at']

    def __str__(self):
        return f"Photo {self.order} de {self.profile.first_name}"


class Preference(models.Model):
    profile = models.OneToOneField(Profile, on_delete=models.CASCADE, related_name='preference')
    min_age = models.PositiveSmallIntegerField(default=18)
    max_age = models.PositiveSmallIntegerField(default=55)
    max_distance_km = models.PositiveIntegerField(default=50)
    preferred_genders = models.JSONField(default=list) # e.g. ['female']
    preferred_intentions = models.JSONField(default=list)
    verified_only = models.BooleanField(default=False)

    def __str__(self):
        return f"Préférences de {self.profile.first_name}"
