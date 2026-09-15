from rest_framework import serializers
from apps.profiles.serializers import PublicProfileSerializer
from .models import Verification, Report, Block

class VerificationSerializer(serializers.ModelSerializer):
    class Meta:
        model = Verification
        fields = ['id', 'selfie', 'requested_pose', 'status', 'rejection_reason', 'created_at']
        read_only_fields = ['id', 'requested_pose', 'status', 'rejection_reason', 'created_at']


class ReportSerializer(serializers.ModelSerializer):
    class Meta:
        model = Report
        fields = ['id', 'reported', 'reason', 'description', 'evidence_message', 'created_at']
        read_only_fields = ['id', 'created_at']


class BlockSerializer(serializers.ModelSerializer):
    blocked_user_id = serializers.UUIDField(write_only=True)
    blocked_profile = serializers.SerializerMethodField(read_only=True)

    class Meta:
        model = Block
        fields = ['id', 'blocked_user_id', 'blocked_profile', 'created_at']
        read_only_fields = ['id', 'created_at']

    def get_blocked_profile(self, obj):
        if hasattr(obj.blocked, 'profile'):
            return PublicProfileSerializer(obj.blocked.profile, context=self.context).data
        return None
