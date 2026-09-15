import uuid
from django.db import models
from django.utils import timezone
from apps.profiles.models import Profile
from apps.discovery.models import Match

MESSAGE_TYPE_CHOICES = [
    ('text', 'Texte'),
    ('image', 'Image'),
    ('audio', 'Message Vocal'),
]

STATUS_CHOICES = [
    ('sent', 'Envoyé'),
    ('delivered', 'Reçu'),
    ('read', 'Lu'),
]

class Conversation(models.Model):
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    match = models.OneToOneField(Match, on_delete=models.CASCADE, related_name='conversation')
    last_message_at = models.DateTimeField(default=timezone.now)
    is_archived_by_a = models.BooleanField(default=False)
    is_archived_by_b = models.BooleanField(default=False)

    class Meta:
        ordering = ['-last_message_at']

    def __str__(self):
        return f"Conversation ({self.id}) - {self.match}"


class Message(models.Model):
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    conversation = models.ForeignKey(Conversation, on_delete=models.CASCADE, related_name='messages')
    sender = models.ForeignKey(Profile, on_delete=models.CASCADE, related_name='sent_messages')
    content = models.TextField(blank=True)
    message_type = models.CharField(max_length=10, choices=MESSAGE_TYPE_CHOICES, default='text')
    media = models.FileField(upload_to='chat/media/', null=True, blank=True)
    audio_duration = models.PositiveIntegerField(default=0, help_text="Durée en secondes")
    reply_to = models.ForeignKey('self', on_delete=models.SET_NULL, null=True, blank=True, related_name='replies')
    status = models.CharField(max_length=10, choices=STATUS_CHOICES, default='sent')
    created_at = models.DateTimeField(auto_now_add=True)
    edited_at = models.DateTimeField(null=True, blank=True)
    deleted_at = models.DateTimeField(null=True, blank=True)

    class Meta:
        ordering = ['-created_at']
        indexes = [
            models.Index(fields=['conversation', '-created_at']),
        ]

    def __str__(self):
        return f"Message {self.id} de {self.sender.first_name}"


class MessageReaction(models.Model):
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    message = models.ForeignKey(Message, on_delete=models.CASCADE, related_name='reactions')
    user = models.ForeignKey(Profile, on_delete=models.CASCADE)
    emoji = models.CharField(max_length=10)
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        unique_together = ('message', 'user', 'emoji')
