from django.contrib import admin
from django.utils.html import format_html
from .models import Conversation, Message

class MessageInline(admin.TabularInline):
    model = Message
    extra = 0
    fields = ('sender', 'content_snippet', 'status', 'created_at')
    readonly_fields = ('created_at',)

    def content_snippet(self, obj):
        return obj.content[:60] if obj.content else ""


@admin.register(Conversation)
class ConversationAdmin(admin.ModelAdmin):
    list_display = ('id', 'participants_display', 'archived_status', 'last_message_at')
    list_filter = ('last_message_at',)
    ordering = ('-last_message_at',)
    inlines = [MessageInline]

    @admin.display(description="Participants")
    def participants_display(self, obj):
        if obj.match:
            return f"{obj.match.profile_a.first_name} 💬 {obj.match.profile_b.first_name}"
        return f"Conversation #{str(obj.id)[:8]}"

    @admin.display(description="Archivé")
    def archived_status(self, obj):
        if obj.is_archived_by_a or obj.is_archived_by_b:
            return format_html('<span style="color: #F59E0B;">Oui</span>')
        return format_html('<span style="color: #10B981;">Non</span>')


@admin.register(Message)
class MessageAdmin(admin.ModelAdmin):
    list_display = ('sender', 'content_snippet', 'message_type', 'status_badge', 'created_at')
    list_filter = ('status', 'message_type', 'created_at')
    search_fields = ('sender__first_name', 'content')
    ordering = ('-created_at',)

    @admin.display(description="Contenu")
    def content_snippet(self, obj):
        return obj.content[:80] + ('...' if len(obj.content) > 80 else '')

    @admin.display(description="Statut")
    def status_badge(self, obj):
        colors = {
            'read': '#10B981',
            'delivered': '#3B82F6',
            'sent': '#6B7280',
        }
        color = colors.get(obj.status, '#6B7280')
        return format_html('<span style="background-color: {}; color: white; padding: 4px 8px; border-radius: 12px; font-weight: bold; font-size: 11px;">{}</span>', color, obj.status.upper())
