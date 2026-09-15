from rest_framework import serializers
from apps.profiles.serializers import PublicProfileSerializer
from .models import Conversation, Message, MessageReaction

class MessageReactionSerializer(serializers.ModelSerializer):
    user_id = serializers.ReadOnlyField(source='user.id')

    class Meta:
        model = MessageReaction
        fields = ['id', 'user_id', 'emoji', 'created_at']


class MessageSerializer(serializers.ModelSerializer):
    sender_id = serializers.ReadOnlyField(source='sender.id')
    sender_name = serializers.ReadOnlyField(source='sender.first_name')
    media_url = serializers.SerializerMethodField()
    reactions = MessageReactionSerializer(many=True, read_only=True)

    class Meta:
        model = Message
        fields = [
            'id', 'conversation_id', 'sender_id', 'sender_name', 'content',
            'message_type', 'media', 'media_url', 'audio_duration', 'reply_to',
            'status', 'created_at', 'edited_at', 'deleted_at', 'reactions'
        ]
        read_only_fields = ['id', 'sender_id', 'sender_name', 'status', 'created_at']

    def get_media_url(self, obj):
        request = self.context.get('request')
        if obj.media and hasattr(obj.media, 'url'):
            return request.build_absolute_uri(obj.media.url) if request else obj.media.url
        return None


class ConversationSerializer(serializers.ModelSerializer):
    other_profile = serializers.SerializerMethodField()

    last_message = serializers.SerializerMethodField()
    unread_count = serializers.SerializerMethodField()

    class Meta:
        model = Conversation
        fields = ['id', 'last_message_at', 'other_profile', 'last_message', 'unread_count']

    def get_other_profile(self, obj):
        request = self.context.get('request')
        current_profile = request.user.profile if request else None
        other = obj.match.profile_b if obj.match.profile_a == current_profile else obj.match.profile_a
        return PublicProfileSerializer(other, context=self.context).data

    def get_last_message(self, obj):
        last_msg = obj.messages.order_by('-created_at').first()
        if last_msg:
            return MessageSerializer(last_msg, context=self.context).data
        return None

    def get_unread_count(self, obj):
        request = self.context.get('request')
        if not request:
            return 0
        current_profile = request.user.profile
        return obj.messages.filter(status__in=['sent', 'delivered']).exclude(sender=current_profile).count()
