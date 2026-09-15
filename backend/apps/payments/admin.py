from django.contrib import admin
from django.utils.html import format_html
from .models import Plan, Subscription, Transaction

@admin.register(Plan)
class PlanAdmin(admin.ModelAdmin):
    list_display = ('name_fr', 'price_display', 'duration_days', 'code', 'is_popular_badge')
    search_fields = ('name_fr', 'code')

    @admin.display(description="Tarif")
    def price_display(self, obj):
        return format_html('<span style="font-weight: bold; color: #10B981;">{} FCFA</span>', obj.price_fcfa)

    @admin.display(description="Populaire")
    def is_popular_badge(self, obj):
        if obj.is_popular:
            return format_html('<span style="background-color: #F59E0B; color: black; padding: 2px 8px; border-radius: 10px; font-weight: bold;">⭐ TOP</span>')
        return "-"


@admin.register(Subscription)
class SubscriptionAdmin(admin.ModelAdmin):
    list_display = ('profile', 'plan', 'is_active_badge', 'start_date', 'end_date')
    list_filter = ('is_active', 'start_date')
    search_fields = ('profile__first_name', 'profile__user__phone_number')

    @admin.display(description="Actif")
    def is_active_badge(self, obj):
        if obj.is_active:
            return format_html('<span style="background-color: #10B981; color: white; padding: 4px 8px; border-radius: 12px; font-weight: bold;">ACTIF</span>')
        return format_html('<span style="color: #6B7280;">EXPIRÉ</span>')


@admin.register(Transaction)
class TransactionAdmin(admin.ModelAdmin):
    list_display = ('transaction_ref', 'profile', 'plan', 'amount_display', 'payment_method_badge', 'status_badge', 'created_at')
    list_filter = ('payment_method', 'status', 'created_at')
    search_fields = ('transaction_ref', 'profile__first_name', 'phone_number')
    ordering = ('-created_at',)

    @admin.display(description="Montant")
    def amount_display(self, obj):
        return format_html('<span style="font-weight: bold;">{} FCFA</span>', obj.amount_fcfa)

    @admin.display(description="Mode de paiement")
    def payment_method_badge(self, obj):
        colors = {
            'orange_money': '#FF7900',
            'mtn_momo': '#FFCC00',
            'stripe': '#635BFF',
        }
        color = colors.get(obj.payment_method, '#6B7280')
        text_color = 'black' if obj.payment_method == 'mtn_momo' else 'white'
        return format_html('<span style="background-color: {}; color: {}; padding: 4px 8px; border-radius: 12px; font-weight: bold; font-size: 11px;">{}</span>', color, text_color, obj.payment_method.upper().replace('_', ' '))

    @admin.display(description="Statut")
    def status_badge(self, obj):
        colors = {
            'completed': '#10B981',
            'pending': '#F59E0B',
            'failed': '#EF4444',
        }
        color = colors.get(obj.status, '#6B7280')
        return format_html('<span style="background-color: {}; color: white; padding: 4px 8px; border-radius: 12px; font-weight: bold; font-size: 11px;">{}</span>', color, obj.status.upper())
