from rest_framework import serializers
from .models import DeviceToken, Notification

class DeviceTokenSerializer(serializers.ModelSerializer):
    class Meta:
        model = DeviceToken
        fields = ['token', 'platform']


class NotificationSerializer(serializers.ModelSerializer):
    class Meta:
        model = Notification
        fields = ['id', 'type', 'title_fr', 'title_en', 'body_fr', 'body_en', 'data', 'is_read', 'created_at']
