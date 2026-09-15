from rest_framework import status, permissions, generics
from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework.pagination import CursorPagination
from django.db.models import Q
from django.utils import timezone

from .models import Conversation, Message, MessageReaction
from .serializers import ConversationSerializer, MessageSerializer, MessageReactionSerializer

class MessageCursorPagination(CursorPagination):
    page_size = 30
    ordering = '-created_at'


class ConversationListView(generics.ListAPIView):
    permission_classes = [permissions.IsAuthenticated]
    serializer_class = ConversationSerializer

    def get_queryset(self):
        profile = self.request.user.profile
        return Conversation.objects.filter(
            match__is_active=True
        ).filter(
            Q(match__profile_a=profile) | Q(match__profile_b=profile)
        ).order_by('-last_message_at')


class ConversationDetailView(APIView):
    permission_classes = [permissions.IsAuthenticated]

    def get(self, request, conversation_id):
        profile = request.user.profile
        try:
            conv = Conversation.objects.get(id=conversation_id, match__is_active=True)
            if conv.match.profile_a != profile and conv.match.profile_b != profile:
                return Response({"success": False, "message": "Accès refusé."}, status=status.HTTP_403_FORBIDDEN)
            serializer = ConversationSerializer(conv, context={'request': request})
            return Response(serializer.data)
        except Conversation.DoesNotExist:
            return Response({"success": False, "message": "Conversation introuvable."}, status=status.HTTP_404_NOT_FOUND)


class MessageListView(generics.ListCreateAPIView):
    permission_classes = [permissions.IsAuthenticated]
    serializer_class = MessageSerializer
    pagination_class = MessageCursorPagination

    def get_queryset(self):
        conversation_id = self.kwargs['conversation_id']
        return Message.objects.filter(conversation_id=conversation_id).order_by('-created_at')

    def perform_create(self, serializer):
        conversation_id = self.kwargs['conversation_id']
        conv = Conversation.objects.get(id=conversation_id)
        msg = serializer.save(conversation=conv, sender=self.request.user.profile)
        conv.last_message_at = timezone.now()
        conv.save()


class MarkMessageReadView(APIView):
    permission_classes = [permissions.IsAuthenticated]

    def patch(self, request, message_id):
        try:
            msg = Message.objects.get(id=message_id)
            if msg.sender != request.user.profile:
                msg.status = 'read'
                msg.save()
            return Response({"success": True, "message_id": str(msg.id), "status": msg.status})
        except Message.DoesNotExist:
            return Response({"success": False, "message": "Message introuvable."}, status=status.HTTP_404_NOT_FOUND)


class MessageReactionView(APIView):
    permission_classes = [permissions.IsAuthenticated]

    def post(self, request, message_id):
        try:
            msg = Message.objects.get(id=message_id)
            emoji = request.data.get('emoji', '❤️')
            reaction, created = MessageReaction.objects.get_or_create(
                message=msg,
                user=request.user.profile,
                emoji=emoji
            )
            return Response(MessageReactionSerializer(reaction).data, status=status.HTTP_201_CREATED)
        except Message.DoesNotExist:
            return Response({"success": False, "message": "Message introuvable."}, status=status.HTTP_404_NOT_FOUND)
