from django.urls import path
from .views import (
    ConversationListView, ConversationDetailView, MessageListView,
    MarkMessageReadView, MessageReactionView
)

urlpatterns = [
    path('conversations/', ConversationListView.as_view(), name='chat-conversations-list'),
    path('conversations/<uuid:conversation_id>/', ConversationDetailView.as_view(), name='chat-conversation-detail'),
    path('conversations/<uuid:conversation_id>/messages/', MessageListView.as_view(), name='chat-messages-list'),
    path('messages/<uuid:message_id>/read/', MarkMessageReadView.as_view(), name='chat-message-read'),
    path('messages/<uuid:message_id>/reactions/', MessageReactionView.as_view(), name='chat-message-reaction'),
]
