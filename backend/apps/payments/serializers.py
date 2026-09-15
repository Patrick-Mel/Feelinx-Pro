from rest_framework import serializers
from .models import Plan, Subscription, Transaction

class PlanSerializer(serializers.ModelSerializer):
    class Meta:
        model = Plan
        fields = ['code', 'name_fr', 'name_en', 'duration_days', 'price_xaf', 'is_active', 'is_popular']


class SubscribeRequestSerializer(serializers.Serializer):
    plan_code = serializers.CharField()
    provider = serializers.ChoiceField(choices=['mtn', 'orange', 'mock'])
    phone_number = serializers.CharField()


class TransactionSerializer(serializers.ModelSerializer):
    plan = PlanSerializer(read_only=True)

    class Meta:
        model = Transaction
        fields = ['id', 'plan', 'amount_xaf', 'provider', 'provider_reference', 'phone_number', 'status', 'created_at', 'completed_at']


class SubscriptionSerializer(serializers.ModelSerializer):
    plan = PlanSerializer(read_only=True)

    class Meta:
        model = Subscription
        fields = ['id', 'plan', 'started_at', 'expires_at', 'status', 'auto_renew']
