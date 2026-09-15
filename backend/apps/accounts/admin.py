from django.contrib import admin
from django.contrib.auth.admin import UserAdmin as BaseUserAdmin
from django.utils.html import format_html
from .models import User, OTPCode

@admin.register(User)
class UserAdmin(BaseUserAdmin):
    list_display = ('phone_number', 'is_phone_verified_badge', 'is_staff', 'is_superuser', 'is_active', 'date_joined')
    list_filter = ('is_phone_verified', 'is_staff', 'is_superuser', 'is_active', 'date_joined')
    search_fields = ('phone_number', 'id')
    ordering = ('-date_joined',)
    
    fieldsets = (
        ('Identifiants', {'fields': ('phone_number', 'password')}),
        ('Vérification & Statuts', {'fields': ('is_phone_verified', 'is_active', 'is_staff', 'is_superuser')}),
        ('Dates', {'fields': ('last_login', 'date_joined')}),
    )
    add_fieldsets = (
        (None, {
            'classes': ('wide',),
            'fields': ('phone_number', 'password', 'is_phone_verified', 'is_staff', 'is_superuser'),
        }),
    )

    @admin.display(description="Vérifié")
    def is_phone_verified_badge(self, obj):
        if obj.is_phone_verified:
            return format_html('<span style="background-color: #10B981; color: white; padding: 4px 8px; border-radius: 12px; font-weight: bold; font-size: 11px;">✓ VÉRIFIÉ</span>')
        return format_html('<span style="background-color: #6B7280; color: white; padding: 4px 8px; border-radius: 12px; font-size: 11px;">NON VÉRIFIÉ</span>')


@admin.register(OTPCode)
class OTPCodeAdmin(admin.ModelAdmin):
    list_display = ('phone_number', 'code_preview', 'attempts', 'is_used_badge', 'expires_at', 'created_at')
    list_filter = ('is_used', 'created_at')
    search_fields = ('phone_number',)
    readonly_fields = ('code_hash', 'ip_address', 'created_at')
    ordering = ('-created_at',)

    @admin.display(description="Code (Masqué)")
    def code_preview(self, obj):
        return "••••••"

    @admin.display(description="Utilisé")
    def is_used_badge(self, obj):
        if obj.is_used:
            return format_html('<span style="color: #10B981; font-weight: bold;">✓ OUI</span>')
        return format_html('<span style="color: #EF4444; font-weight: bold;">✗ NON</span>')
