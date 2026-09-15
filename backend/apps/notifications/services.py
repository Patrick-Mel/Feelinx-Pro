import logging
import requests
from django.conf import settings
from .models import Notification, DeviceToken

logger = logging.getLogger(__name__)

class PushNotificationService:
    @staticmethod
    def send_push_to_user(user, title_fr: str, body_fr: str, title_en: str, body_en: str, data: dict = None) -> bool:
        if data is None:
            data = {}

        # 1. Record notification in DB
        notif = Notification.objects.create(
            user=user,
            type=data.get('type', 'system'),
            title_fr=title_fr,
            title_en=title_en,
            body_fr=body_fr,
            body_en=body_en,
            data=data
        )

        # 2. Get user device tokens
        tokens = list(DeviceToken.objects.filter(user=user, is_active=True).values_list('token', flat=True))
        if not tokens:
            return True

        app_id = getattr(settings, 'ONESIGNAL_APP_ID', '')
        rest_key = getattr(settings, 'ONESIGNAL_REST_API_KEY', '')

        if not app_id or app_id == 'mock-onesignal-app-id':
            logger.info(f"[MOCK PUSH] Sent to {user.phone_number}: {title_fr} - {body_fr}")
            return True

        # Call OneSignal REST API
        try:
            url = "https://onesignal.com/api/v1/notifications"
            headers = {
                "Content-Type": "application/json; charset=utf-8",
                "Authorization": f"Basic {rest_key}"
            }
            payload = {
                "app_id": app_id,
                "include_player_ids": tokens,
                "headings": {"fr": title_fr, "en": title_en},
                "contents": {"fr": body_fr, "en": body_en},
                "data": data
            }
            res = requests.post(url, json=payload, headers=headers, timeout=10)
            return res.status_code == 200
        except Exception as e:
            logger.error(f"OneSignal Push Notification Error: {e}")
            return False
