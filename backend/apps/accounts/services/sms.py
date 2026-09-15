import logging
import requests
from django.conf import settings

logger = logging.getLogger(__name__)

class BaseSMSProvider:
    def send_sms(self, phone_number: str, message: str) -> bool:
        raise NotImplementedError()


class ConsoleSMSProvider(BaseSMSProvider):
    def send_sms(self, phone_number: str, message: str) -> bool:
        print("\n==================================================")
        print(f"[FEELINX SMS DEBUG] Destinataire: {phone_number}")
        print(f"[FEELINX SMS DEBUG] Message: {message}")
        print("==================================================\n")
        logger.info(f"[CONSOLE SMS] Sent to {phone_number}: {message}")
        return True


class TwilioSMSProvider(BaseSMSProvider):
    def send_sms(self, phone_number: str, message: str) -> bool:
        account_sid = getattr(settings, 'TWILIO_ACCOUNT_SID', None)
        auth_token = getattr(settings, 'TWILIO_AUTH_TOKEN', None)
        from_number = getattr(settings, 'TWILIO_PHONE_NUMBER', None)

        if not all([account_sid, auth_token, from_number]):
            logger.error("Configuration Twilio incomplète.")
            return False

        try:
            url = f"https://api.twilio.com/2010-04-01/Accounts/{account_sid}/Messages.json"
            response = requests.post(
                url,
                data={"To": phone_number, "From": from_number, "Body": message},
                auth=(account_sid, auth_token),
                timeout=10,
            )
            return response.status_code in (200, 201)
        except Exception as e:
            logger.error(f"Erreur envoi SMS Twilio: {e}")
            return False


class NexahSMSProvider(BaseSMSProvider):
    def send_sms(self, phone_number: str, message: str) -> bool:
        api_key = getattr(settings, 'NEXAH_API_KEY', None)
        sender_id = getattr(settings, 'NEXAH_SENDER_ID', 'FEELINX')

        if not api_key:
            logger.error("Configuration Nexah SMS incomplète.")
            return False

        try:
            url = "https://api.nexah.net/v1/sms/send"
            payload = {
                "api_key": api_key,
                "to": phone_number,
                "message": message,
                "sender_id": sender_id,
            }
            response = requests.post(url, json=payload, timeout=10)
            return response.status_code == 200
        except Exception as e:
            logger.error(f"Erreur envoi SMS Nexah: {e}")
            return False


def get_sms_provider() -> BaseSMSProvider:
    provider_name = getattr(settings, 'SMS_PROVIDER', 'console').lower()
    if provider_name == 'twilio':
        return TwilioSMSProvider()
    elif provider_name == 'nexah':
        return NexahSMSProvider()
    return ConsoleSMSProvider()
