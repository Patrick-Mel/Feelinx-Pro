from django.contrib import admin
from django.utils.html import format_html
from .models import Swipe, Match, ProfileView, Boost

@admin.register(Swipe)
class SwipeAdmin(admin.ModelAdmin):
    list_display = ('swiper', 'action_badge', 'swiped', 'created_at')
    list_filter = ('action', 'created_at')
    search_fields = ('swiper__first_name', 'swiped__first_name')
    ordering = ('-created_at',)

    @admin.display(description="Action")
    def action_badge(self, obj):
        colors = {
            'like': '#10B981',
            'superlike': '#3B82F6',
            'nope': '#EF4444',
        }
        color = colors.get(obj.action, '#6B7280')
        return format_html('<span style="background-color: {}; color: white; padding: 4px 10px; border-radius: 12px; font-weight: bold; font-size: 11px;">{}</span>', color, obj.action.upper())


@admin.register(Match)
class MatchAdmin(admin.ModelAdmin):
    list_display = ('profile_a', 'match_icon', 'profile_b', 'is_active', 'matched_at')
    list_filter = ('is_active', 'matched_at')
    search_fields = ('profile_a__first_name', 'profile_b__first_name')
    ordering = ('-matched_at',)

    @admin.display(description="Match")
    def match_icon(self, obj):
        return format_html('<span style="font-size: 18px;">🔥 ❤️ 🔥</span>')


@admin.register(ProfileView)
class ProfileViewAdmin(admin.ModelAdmin):
    list_display = ('viewer', 'viewed', 'viewed_at')
    list_filter = ('viewed_at',)
    search_fields = ('viewer__first_name', 'viewed__first_name')
    ordering = ('-viewed_at',)


@admin.register(Boost)
class BoostAdmin(admin.ModelAdmin):
    list_display = ('profile', 'views_gained', 'started_at', 'ends_at')
    list_filter = ('started_at',)
    search_fields = ('profile__first_name',)
    ordering = ('-started_at',)
