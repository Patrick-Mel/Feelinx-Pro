from django.contrib import admin
from django.utils.html import format_html
from django.utils import timezone
from datetime import timedelta
from .models import Profile, Photo, Interest, Preference, ProfileInterest

class PhotoInline(admin.TabularInline):
    model = Photo
    extra = 0
    fields = ('photo_preview', 'image', 'is_primary', 'is_approved', 'order')
    readonly_fields = ('photo_preview',)

    def photo_preview(self, obj):
        if obj.image:
            url = obj.image.url if hasattr(obj.image, 'url') else str(obj.image)
            return format_html('<img src="{}" style="width: 50px; height: 50px; object-fit: cover; border-radius: 8px;" />', url)
        return "Pas d'image"
    photo_preview.short_description = "Aperçu"


class PreferenceInline(admin.StackedInline):
    model = Preference
    can_delete = False


@admin.register(Profile)
class ProfileAdmin(admin.ModelAdmin):
    list_display = ('avatar_preview', 'first_name', 'age_display', 'gender', 'city', 'intention_badge', 'verified_badge', 'premium_badge', 'completion_progress', 'created_at')
    list_filter = ('gender', 'seeking', 'intention', 'is_verified', 'is_premium', 'city')
    search_fields = ('first_name', 'city', 'user__phone_number', 'bio')
    readonly_fields = ('created_at', 'updated_at', 'last_seen', 'age_display')
    inlines = [PhotoInline, PreferenceInline]
    actions = ['make_verified', 'make_premium_30_days', 'revoke_premium']

    fieldsets = (
        ('Identité & Bio', {'fields': ('user', 'first_name', 'birth_date', 'gender', 'seeking', 'bio')}),
        ('Localisation & Préférences', {'fields': ('city', 'neighborhood', 'latitude', 'longitude', 'intention')}),
        ('Statuts & Privilèges', {'fields': ('is_verified', 'verification_status', 'is_premium', 'premium_until', 'is_incognito')}),
        ('Métadonnées', {'fields': ('last_seen', 'created_at', 'updated_at')}),
    )

    @admin.display(description="Photo")
    def avatar_preview(self, obj):
        primary_photo = obj.photos.filter(is_primary=True).first() or obj.photos.first()
        if primary_photo and primary_photo.image:
            url = primary_photo.image.url if hasattr(primary_photo.image, 'url') else str(primary_photo.image)
            return format_html('<img src="{}" style="width: 44px; height: 44px; object-fit: cover; border-radius: 50%; border: 2px solid #FF5A5F;" />', url)
        return format_html('<div style="width: 44px; height: 44px; border-radius: 50%; background: #374151; display: flex; align-items: center; justify-content: center; color: white; font-weight: bold;">{}</div>', obj.first_name[0] if obj.first_name else '?')

    @admin.display(description="Âge")
    def age_display(self, obj):
        return f"{obj.age} ans"

    @admin.display(description="Intention")
    def intention_badge(self, obj):
        labels = {
            'serious': ('Relation Sérieuse', '#EF4444'),
            'casual': ('Sorties & Fun', '#F59E0B'),
            'friendship': ('Amitié', '#10B981'),
            'networking': ('Pro & Business', '#3B82F6'),
            'undecided': ('Découverte', '#6B7280'),
        }
        text, color = labels.get(obj.intention, (obj.intention, '#6B7280'))
        return format_html('<span style="background-color: {}; color: white; padding: 4px 8px; border-radius: 12px; font-weight: 600; font-size: 11px;">{}</span>', color, text)

    @admin.display(description="Certifié 🛡️")
    def verified_badge(self, obj):
        if obj.is_verified:
            return format_html('<span style="background-color: #3B82F6; color: white; padding: 4px 8px; border-radius: 12px; font-weight: bold; font-size: 11px;">🛡️ CERTIFIÉ</span>')
        return format_html('<span style="color: #9CA3AF; font-size: 11px;">Standard</span>')

    @admin.display(description="Premium 👑")
    def premium_badge(self, obj):
        if obj.is_premium_active:
            return format_html('<span style="background-color: #F59E0B; color: black; padding: 4px 8px; border-radius: 12px; font-weight: bold; font-size: 11px;">👑 PREMIUM</span>')
        return format_html('<span style="color: #9CA3AF; font-size: 11px;">Gratuit</span>')

    @admin.display(description="Complétion")
    def completion_progress(self, obj):
        score = obj.profile_completion
        color = '#10B981' if score >= 80 else ('#F59E0B' if score >= 50 else '#EF4444')
        return format_html('<div style="width: 80px; background: #374151; border-radius: 8px; overflow: hidden; height: 14px;"><div style="width: {}%; background: {}; height: 100%; text-align: center; color: white; font-size: 9px; font-weight: bold; line-height: 14px;">{}%</div></div>', score, color, score)

    @admin.action(description="🛡️ Valider la certification (Badge Vérifié)")
    def make_verified(self, request, queryset):
        count = queryset.update(is_verified=True, verification_status='approved')
        self.message_user(request, f"{count} profil(s) vérifié(s) avec succès.")

    @admin.action(description="👑 Activer Feelinx Premium (30 Jours)")
    def make_premium_30_days(self, request, queryset):
        until = timezone.now() + timedelta(days=30)
        count = queryset.update(is_premium=True, premium_until=until)
        self.message_user(request, f"Feelinx Premium activé pour {count} profil(s) pour 30 jours.")

    @admin.action(description="❌ Révoquer le statut Premium")
    def revoke_premium(self, request, queryset):
        count = queryset.update(is_premium=False, premium_until=None)
        self.message_user(request, f"Statut Premium révoqué pour {count} profil(s).")


@admin.register(Photo)
class PhotoAdmin(admin.ModelAdmin):
    list_display = ('photo_preview', 'profile', 'is_primary', 'is_approved', 'order', 'uploaded_at')
    list_filter = ('is_primary', 'is_approved', 'uploaded_at')
    search_fields = ('profile__first_name', 'profile__user__phone_number')
    ordering = ('-uploaded_at',)

    @admin.display(description="Visuel")
    def photo_preview(self, obj):
        if obj.image:
            url = obj.image.url if hasattr(obj.image, 'url') else str(obj.image)
            return format_html('<img src="{}" style="width: 60px; height: 60px; object-fit: cover; border-radius: 8px;" />', url)
        return "Pas d'image"


@admin.register(Interest)
class InterestAdmin(admin.ModelAdmin):
    list_display = ('emoji', 'name_fr', 'code', 'category')
    list_filter = ('category',)
    search_fields = ('name_fr', 'code')
