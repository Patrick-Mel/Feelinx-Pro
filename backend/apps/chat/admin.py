from django.contrib import admin
from django.utils.html import format_html
from .models import Conversation, Message

class MessageInline(admin.TabularInline):
    model = Message
    extra = 0
    fields = ('sender', 'content_snippet', 'is_read', 'sent_at')
    readonly_fields = ('sent_at',)

    def content_snippet(self, obj):
        return obj.content[:60] if obj.content else ""


@admin.register(Conversation)
class ConversationAdmin(admin.ModelAdmin):
    list_display = ('id', 'participants_display', 'is_active', 'messages_count', 'updated_at')
    list_filter = ('is_active', 'updated_at')
    ordering = ('-updated_at',)
    inlines = [MessageInline]

    @admin.display(description="Participants")
    def participants_display(self, obj):
        if obj.match:
            return f"{obj.match.profile_a.first_name} 💬 {obj.match.profile_b.first_name}"
        return f"Conversation #{str(obj.id)[:8]}"

    @admin.display(description="Messages")
    def messages_count(self, obj):
        count = obj.messages.count()
        return format_html('<span style="background: #374151; color: white; padding: 2px 8px; border-radius: 10px; font-weight: bold;">{} msgs</span>', count)


@admin.register(Message)
class MessageAdmin(admin.ModelAdmin):
    list_display = ('sender', 'content_snippet', 'is_read_badge', 'sent_at')
    list_filter = ('is_read', 'sent_at')
    search_fields = ('sender__first_name', 'content')
    ordering = ('-sent_at',)

    @admin.display(description="Message")
    def content_snippet(self, obj):
        return obj.content[:80] + ('...' if len(obj.content) > 80 else '')

    @admin.display(description="Lu")
    def is_read_badge(self, obj):
        if obj.is_read:
            return format_html('<span style="color: #10B981; font-weight: bold;">✓✓ LU</span>')
        return format_html('<span style="color: #6B7280;">ENVOYÉ</span>')
