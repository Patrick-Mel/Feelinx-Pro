import json
from channels.generic.websocket import AsyncWebsocketConsumer
from channels.db import database_sync_to_async
from django.utils import timezone
from apps.chat.models import Conversation, Message, MessageReaction
from apps.profiles.models import Profile

class ChatConsumer(AsyncWebsocketConsumer):
    async def connect(self):
        self.user = self.scope.get("user")
        if not self.user or self.user.is_anonymous:
            await self.close()
            return

        self.conversation_id = self.scope["url_route"]["kwargs"]["conversation_id"]
        self.room_group_name = f"chat_{self.conversation_id}"

        # Verify user is member of conversation
        is_member = await self.check_conversation_member()
        if not is_member:
            await self.close()
            return

        await self.channel_layer.group_add(self.room_group_name, self.channel_name)
        await self.accept()

    async def disconnect(self, close_code):
        if hasattr(self, 'room_group_name'):
            await self.channel_layer.group_discard(self.room_group_name, self.channel_name)

    async def receive(self, text_data):
        data = json.loads(text_data)
        event_type = data.get("type")

        if event_type == "message.send":
            content = data.get("content", "")
            msg_type = data.get("message_type", "text")
            reply_to_id = data.get("reply_to")

            msg_data = await self.create_message(content, msg_type, reply_to_id)
            await self.channel_layer.group_send(
                self.room_group_name,
                {
                    "type": "chat_message",
                    "data": msg_data
                }
            )

        elif event_type == "typing.start":
            await self.channel_layer.group_send(
                self.room_group_name,
                {"type": "chat_typing", "sender_id": str(self.user.profile.id), "is_typing": True}
            )

        elif event_type == "typing.stop":
            await self.channel_layer.group_send(
                self.room_group_name,
                {"type": "chat_typing", "sender_id": str(self.user.profile.id), "is_typing": False}
            )

        elif event_type == "message.read":
            msg_id = data.get("message_id")
            if msg_id:
                await self.mark_message_read(msg_id)
                await self.channel_layer.group_send(
                    self.room_group_name,
                    {"type": "chat_read_receipt", "message_id": msg_id, "reader_id": str(self.user.profile.id)}
                )

    async def chat_message(self, event):
        await self.send(text_data=json.dumps({"type": "message.new", "message": event["data"]}))

    async def chat_typing(self, event):
        await self.send(text_data=json.dumps({"type": "typing", "sender_id": event["sender_id"], "is_typing": event["is_typing"]}))

    async def chat_read_receipt(self, event):
        await self.send(text_data=json.dumps({"type": "message.read", "message_id": event["message_id"], "reader_id": event["reader_id"]}))

    @database_sync_to_async
    def check_conversation_member(self):
        try:
            profile = self.user.profile
            conv = Conversation.objects.get(id=self.conversation_id)
            return conv.match.profile_a == profile or conv.match.profile_b == profile
        except Exception:
            return False

    @database_sync_to_async
    def create_message(self, content, msg_type, reply_to_id):
        profile = self.user.profile
        conv = Conversation.objects.get(id=self.conversation_id)
        reply_to = Message.objects.filter(id=reply_to_id).first() if reply_to_id else None

        msg = Message.objects.create(
            conversation=conv,
            sender=profile,
            content=content,
            message_type=msg_type,
            reply_to=reply_to,
            status='sent'
        )
        conv.last_message_at = timezone.now()
        conv.save()

        return {
            "id": str(msg.id),
            "conversation_id": str(conv.id),
            "sender_id": str(profile.id),
            "sender_name": profile.first_name,
            "content": msg.content,
            "message_type": msg.message_type,
            "status": msg.status,
            "created_at": msg.created_at.isoformat(),
        }

    @database_sync_to_async
    def mark_message_read(self, msg_id):
        Message.objects.filter(id=msg_id).update(status='read')


class PresenceConsumer(AsyncWebsocketConsumer):
    async def connect(self):
        self.user = self.scope.get("user")
        if not self.user or self.user.is_anonymous:
            await self.close()
            return

        self.group_name = f"user_presence_{self.user.profile.id}"
        await self.channel_layer.group_add(self.group_name, self.channel_name)
        await self.accept()
        await self.update_last_seen()

    async def disconnect(self, close_code):
        if hasattr(self, 'group_name'):
            await self.channel_layer.group_discard(self.group_name, self.channel_name)

    @database_sync_to_async
    def update_last_seen(self):
        if hasattr(self.user, 'profile'):
            self.user.profile.last_seen = timezone.now()
            self.user.profile.save()
