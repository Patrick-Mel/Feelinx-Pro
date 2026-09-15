from rest_framework import serializers
from .models import Profile, Interest, Photo, Preference

class InterestSerializer(serializers.ModelSerializer):
    class Meta:
        model = Interest
        fields = ['id', 'code', 'name_fr', 'name_en', 'emoji', 'category']


class PhotoSerializer(serializers.ModelSerializer):
    url = serializers.SerializerMethodField()
    thumbnail_url = serializers.SerializerMethodField()

    class Meta:
        model = Photo
        fields = ['id', 'image', 'thumbnail', 'url', 'thumbnail_url', 'order', 'is_primary', 'is_approved']
        read_only_fields = ['id', 'url', 'thumbnail_url', 'is_approved']

    def get_url(self, obj):
        request = self.context.get('request')
        if obj.image and hasattr(obj.image, 'url'):
            return request.build_absolute_uri(obj.image.url) if request else obj.image.url
        return ""

    def get_thumbnail_url(self, obj):
        request = self.context.get('request')
        img = obj.thumbnail or obj.image
        if img and hasattr(img, 'url'):
            return request.build_absolute_uri(img.url) if request else img.url
        return ""


class PreferenceSerializer(serializers.ModelSerializer):
    class Meta:
        model = Preference
        fields = ['min_age', 'max_age', 'max_distance_km', 'preferred_genders', 'preferred_intentions', 'verified_only']


class ProfileSerializer(serializers.ModelSerializer):
    age = serializers.IntegerField(read_only=True)
    is_premium_active = serializers.BooleanField(read_only=True)
    profile_completion = serializers.IntegerField(read_only=True)
    photos = PhotoSerializer(many=True, read_only=True)
    interests = InterestSerializer(many=True, read_only=True)
    interest_ids = serializers.ListField(child=serializers.UUIDField(), write_only=True, required=False)
    preference = PreferenceSerializer(read_only=True)

    class Meta:
        model = Profile
        fields = [
            'id', 'first_name', 'birth_date', 'age', 'gender', 'seeking', 'intention',
            'bio', 'city', 'neighborhood', 'latitude', 'longitude', 'is_verified',
            'verification_status', 'is_premium', 'is_premium_active', 'premium_until',
            'is_incognito', 'hide_distance', 'hide_age', 'profile_completion',
            'personality_answers', 'last_seen', 'photos', 'interests', 'interest_ids',
            'preference', 'created_at'
        ]
        read_only_fields = ['id', 'is_verified', 'verification_status', 'is_premium', 'premium_until', 'created_at']

    def update(self, instance, validated_data):
        interest_ids = validated_data.pop('interest_ids', None)
        profile = super().update(instance, validated_data)
        if interest_ids is not None:
            profile.interests.set(Interest.objects.filter(id__in=interest_ids))
        return profile


class PublicProfileSerializer(serializers.ModelSerializer):
    age = serializers.SerializerMethodField()
    distance_km = serializers.SerializerMethodField()
    photos = PhotoSerializer(many=True, read_only=True)
    interests = InterestSerializer(many=True, read_only=True)

    class Meta:
        model = Profile
        fields = [
            'id', 'first_name', 'age', 'gender', 'intention', 'bio', 'city',
            'neighborhood', 'distance_km', 'is_verified', 'is_premium',
            'personality_answers', 'last_seen', 'photos', 'interests'
        ]

    def get_age(self, obj):
        if obj.hide_age:
            return None
        return obj.age

    def get_distance_km(self, obj):
        if obj.hide_distance:
            return None
        return getattr(obj, 'distance_km', 0)
