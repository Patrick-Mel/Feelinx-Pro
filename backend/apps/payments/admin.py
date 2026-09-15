from django.contrib import admin
from django.utils.html import format_html
from .models import Plan, Subscription, Transaction

@admin.register(Plan)
class PlanAdmin(admin.ModelAdmin):
    list_display = ('name_fr', 'price_display', 'duration_days', 'code', 'is_popular_badge')
    search_fields = ('name_fr', 'code')

    @admin.display(description="Tarif")
    def price_display(self, obj):
        return format_html('<span style="font-weight: bold; color: #10B981;">{:,} FCFA</span>', obj.price_xaf)

    @admin.display(description="Populaire")
    def is_popular_badge(self, obj):
        if obj.is_popular:
            return format_html('<span style="background-color: #F59E0B; color: black; padding: 2px 8px; border-radius: 10px; font-weight: bold;">⭐ TOP</span>')
        return "-"


@admin.register(Subscription)
class SubscriptionAdmin(admin.ModelAdmin):
    list_display = ('profile', 'plan', 'status_badge', 'started_at', 'expires_at')
    list_filter = ('status', 'started_at')
    search_fields = ('profile__first_name', 'profile__user__phone_number')

    @admin.display(description="Statut")
    def status_badge(self, obj):
        if obj.status == 'active':
            return format_html('<span style="background-color: #10B981; color: white; padding: 4px 8px; border-radius: 12px; font-weight: bold;">ACTIF</span>')
        return format_html('<span style="color: #6B7280;">{}</span>', obj.status.upper())


@admin.register(Transaction)
class TransactionAdmin(admin.ModelAdmin):
    list_display = ('id_short', 'profile', 'plan', 'amount_display', 'provider_badge', 'status_badge', 'created_at')
    list_filter = ('provider', 'status', 'created_at')
    search_fields = ('provider_reference', 'profile__first_name', 'phone_number')
    ordering = ('-created_at',)

    @admin.display(description="ID Tx")
    def id_short(self, obj):
        return str(obj.id)[:8]

    @admin.display(description="Montant")
    def amount_display(self, obj):
        return format_html('<span style="font-weight: bold;">{:,} FCFA</span>', obj.amount_xaf)

    @admin.display(description="Provider")
    def provider_badge(self, obj):
        colors = {
            'orange': '#FF7900',
            'mtn': '#FFCC00',
            'mock': '#6B7280',
        }
        color = colors.get(obj.provider, '#6B7280')
        text_color = 'black' if obj.provider == 'mtn' else 'white'
        return format_html('<span style="background-color: {}; color: {}; padding: 4px 8px; border-radius: 12px; font-weight: bold; font-size: 11px;">{}</span>', color, text_color, obj.provider.upper())

    @admin.display(description="Statut")
    def status_badge(self, obj):
        colors = {
            'success': '#10B981',
            'pending': '#F59E0B',
            'failed': '#EF4444',
            'cancelled': '#6B7280',
        }
        color = colors.get(obj.status, '#6B7280')
        return format_html('<span style="background-color: {}; color: white; padding: 4px 8px; border-radius: 12px; font-weight: bold; font-size: 11px;">{}</span>', color, obj.status.upper())
