from django.contrib import admin
from django.utils.html import format_html
from django.utils import timezone
from .models import Verification, Report, Block

@admin.register(Verification)
class VerificationAdmin(admin.ModelAdmin):
    list_display = ('selfie_preview', 'profile', 'requested_pose', 'status_badge', 'created_at')
    list_filter = ('status', 'requested_pose', 'created_at')
    search_fields = ('profile__first_name', 'profile__user__phone_number')
    ordering = ('-created_at',)
    actions = ['approve_verification', 'reject_verification']

    @admin.display(description="Selfie")
    def selfie_preview(self, obj):
        if obj.selfie:
            url = obj.selfie.url if hasattr(obj.selfie, 'url') else str(obj.selfie)
            return format_html('<img src="{}" style="width: 60px; height: 60px; object-fit: cover; border-radius: 8px;" />', url)
        return "Pas de photo"

    @admin.display(description="Statut")
    def status_badge(self, obj):
        colors = {
            'pending': '#F59E0B',
            'approved': '#10B981',
            'rejected': '#EF4444',
        }
        color = colors.get(obj.status, '#6B7280')
        return format_html('<span style="background-color: {}; color: white; padding: 4px 10px; border-radius: 12px; font-weight: bold; font-size: 11px;">{}</span>', color, obj.status.upper())

    @admin.action(description="🛡️ Approuver la vérification (Octroyer Badge 🛡️)")
    def approve_verification(self, request, queryset):
        for v in queryset:
            v.status = 'approved'
            v.reviewed_at = timezone.now()
            v.save()
            v.profile.is_verified = True
            v.profile.verification_status = 'approved'
            v.profile.save()
        self.message_user(request, f"{queryset.count()} demande(s) approuvée(s). Badge de vérification accordé.")

    @admin.action(description="❌ Rejeter la vérification")
    def reject_verification(self, request, queryset):
        for v in queryset:
            v.status = 'rejected'
            v.reviewed_at = timezone.now()
            v.save()
            v.profile.is_verified = False
            v.profile.verification_status = 'rejected'
            v.profile.save()
        self.message_user(request, f"{queryset.count()} demande(s) rejetée(s).")


@admin.register(Report)
class ReportAdmin(admin.ModelAdmin):
    list_display = ('reporter', 'reported', 'reason', 'status_badge', 'created_at')
    list_filter = ('status', 'reason', 'created_at')
    search_fields = ('reporter__first_name', 'reported__first_name', 'description')
    ordering = ('-created_at',)
    actions = ['mark_banned', 'mark_resolved', 'mark_dismissed']

    @admin.display(description="Statut")
    def status_badge(self, obj):
        colors = {
            'pending': '#EF4444',
            'reviewed': '#3B82F6',
            'banned': '#7C3AED',
            'dismissed': '#6B7280',
        }
        color = colors.get(obj.status, '#6B7280')
        return format_html('<span style="background-color: {}; color: white; padding: 4px 8px; border-radius: 12px; font-weight: bold; font-size: 11px;">{}</span>', color, obj.status.upper())

    @admin.action(description="🚫 Traiter et Bannir l'utilisateur signalé")
    def mark_banned(self, request, queryset):
        for report in queryset:
            report.status = 'banned'
            report.action_taken = 'User account disabled by admin'
            report.reviewed_at = timezone.now()
            report.save()
            if hasattr(report.reported, 'user'):
                report.reported.user.is_active = False
                report.reported.user.save()
        self.message_user(request, f"{queryset.count()} signalement(s) traité(s) et utilisateur(s) banni(s).")

    @admin.action(description="✓ Marquer comme Résolu")
    def mark_resolved(self, request, queryset):
        count = queryset.update(status='reviewed', reviewed_at=timezone.now())
        self.message_user(request, f"{count} signalement(s) marqué(s) comme résolu(s).")

    @admin.action(description="❌ Classer sans suite (Dismissed)")
    def mark_dismissed(self, request, queryset):
        count = queryset.update(status='dismissed', reviewed_at=timezone.now())
        self.message_user(request, f"{count} signalement(s) classé(s) sans suite.")


@admin.register(Block)
class BlockAdmin(admin.ModelAdmin):
    list_display = ('blocker', 'blocked', 'created_at')
    list_filter = ('created_at',)
    search_fields = ('blocker__phone_number', 'blocked__phone_number')
    ordering = ('-created_at',)
