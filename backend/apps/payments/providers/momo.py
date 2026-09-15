import uuid
import logging
import requests
from django.conf import settings

logger = logging.getLogger(__name__)

class MTNMoMoProvider:
    def __init__(self):
        self.primary_key = getattr(settings, 'MTN_MOMO_PRIMARY_KEY', '')
        self.user_id = getattr(settings, 'MTN_MOMO_USER_ID', '')
        self.api_secret = getattr(settings, 'MTN_MOMO_API_SECRET', '')
        self.target_env = getattr(settings, 'MTN_MOMO_TARGET_ENV', 'sandbox')
        self.base_url = "https://sandbox.momodeveloper.mtn.com" if self.target_env == 'sandbox' else "https://proxy.momoapi.mtn.com"

    def get_auth_token(self) -> str:
        try:
            url = f"{self.base_url}/collection/token/"
            headers = {
                "Ocp-Apim-Subscription-Key": self.primary_key
            }
            res = requests.post(url, headers=headers, auth=(self.user_id, self.api_secret), timeout=10)
            if res.status_code == 200:
                return res.json().get("access_token", "")
        except Exception as e:
            logger.error(f"Erreur obtenant token MTN MoMo: {e}")
        return ""

    def request_to_pay(self, transaction_id: str, phone_number: str, amount_xaf: int, payer_note: str = "Abonnement Feelinx") -> dict:
        token = self.get_auth_token()
        ref_id = str(transaction_id)
        
        # Clean phone number for MTN API format
        clean_phone = phone_number.replace("+", "").replace(" ", "")

        url = f"{self.base_url}/collection/v1_0/requesttopay"
        headers = {
            "Authorization": f"Bearer {token}",
            "X-Reference-Id": ref_id,
            "X-Target-Environment": self.target_env,
            "Ocp-Apim-Subscription-Key": self.primary_key,
            "Content-Type": "application/json"
        }
        payload = {
            "amount": str(amount_xaf),
            "currency": "XAF",
            "externalId": ref_id,
            "payer": {
                "partyIdType": "MSISDN",
                "partyId": clean_phone
            },
            "payerMessage": payer_note,
            "payeeNote": "Feelinx Premium"
        }

        try:
            res = requests.post(url, json=payload, headers=headers, timeout=15)
            if res.status_code == 202:
                return {"success": True, "reference_id": ref_id, "status": "PENDING"}
            return {"success": False, "status": "FAILED", "error": res.text}
        except Exception as e:
            logger.error(f"MTN MoMo requestToPay error: {e}")
            return {"success": False, "status": "FAILED", "error": str(e)}

    def check_status(self, reference_id: str) -> dict:
        token = self.get_auth_token()
        url = f"{self.base_url}/collection/v1_0/requesttopay/{reference_id}"
        headers = {
            "Authorization": f"Bearer {token}",
            "X-Target-Environment": self.target_env,
            "Ocp-Apim-Subscription-Key": self.primary_key
        }
        try:
            res = requests.get(url, headers=headers, timeout=10)
            if res.status_code == 200:
                data = res.json()
                momo_status = data.get("status") # SUCCESSFUL, PENDING, FAILED
                mapped_status = 'success' if momo_status == 'SUCCESSFUL' else ('failed' if momo_status == 'FAILED' else 'pending')
                return {"status": mapped_status, "raw": data}
        except Exception as e:
            logger.error(f"MTN MoMo status check error: {e}")
        return {"status": "pending", "raw": {}}
