import logging
import requests
from django.conf import settings

logger = logging.getLogger(__name__)

class OrangeMoneyProvider:
    def __init__(self):
        self.client_id = getattr(settings, 'ORANGE_MONEY_CLIENT_ID', '')
        self.client_secret = getattr(settings, 'ORANGE_MONEY_CLIENT_SECRET', '')
        self.merchant_key = getattr(settings, 'ORANGE_MONEY_MERCHANT_KEY', '')
        self.env = getattr(settings, 'ORANGE_MONEY_ENV', 'sandbox')
        self.base_url = "https://api.orange.com"

    def get_token(self) -> str:

        try:
            url = f"{self.base_url}/oauth/v3/token"
            headers = {"Content-Type": "application/x-www-form-length-encoded"}
            res = requests.post(url, data={"grant_type": "client_credentials"}, auth=(self.client_id, self.client_secret), timeout=10)
            if res.status_code == 200:
                return res.json().get("access_token", "")
        except Exception as e:
            logger.error(f"Orange Money auth error: {e}")
        return ""

    def initiate_payment(self, transaction_id: str, phone_number: str, amount_xaf: int) -> dict:
        token = self.get_token()
        ref = str(transaction_id)
        url = f"{self.base_url}/orange-money-webpay/cm/v1/webpayment"
        headers = {
            "Authorization": f"Bearer {token}",
            "Content-Type": "application/json"
        }
        payload = {
            "merchant_key": self.merchant_key,
            "currency": "XAF",
            "order_id": ref,
            "amount": amount_xaf,
            "return_url": "https://feelinx.app/payment/return",
            "cancel_url": "https://feelinx.app/payment/cancel",
            "notif_url": "https://api.feelinx.app/api/v1/payments/webhook/orange/",
            "lang": "fr",
            "reference": "Feelinx Premium"
        }
        try:
            res = requests.post(url, json=payload, headers=headers, timeout=10)
            if res.status_code == 201:
                data = res.json()
                return {"success": True, "reference_id": data.get("pay_token"), "status": "PENDING", "payment_url": data.get("payment_url")}
        except Exception as e:
            logger.error(f"Orange Money initiate error: {e}")
        return {"success": False, "status": "FAILED"}
