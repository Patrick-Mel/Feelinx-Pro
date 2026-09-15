from rest_framework import serializers
from apps.profiles.serializers import PublicProfileSerializer
from .models import Swipe, Match

class SwipeRequestSerializer(serializers.Serializer):
    target_id = serializers.UUIDField()
    action = serializers.ChoiceField(choices=['like', 'nope', 'superlike'])


class MatchSerializer(serializers.ModelSerializer):
    other_profile = serializers.SerializerMethodField()

    conversation_id = serializers.SerializerMethodField()

    class Meta:
        model = Match
        fields = ['id', 'matched_at', 'is_active', 'other_profile', 'conversation_id']

    def get_other_profile(self, obj):
        request = self.context.get('request')
        current_profile = request.user.profile if request else None
        other = obj.profile_b if obj.profile_a == current_profile else obj.profile_a
        return PublicProfileSerializer(other, context=self.context).data

    def get_conversation_id(self, obj):
        if hasattr(obj, 'conversation'):
            return str(obj.conversation.id)
        return None
