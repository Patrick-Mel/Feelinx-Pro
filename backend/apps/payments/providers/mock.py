import time
import logging

logger = logging.getLogger(__name__)

class MockPaymentProvider:
    """
    Mock payment provider for local development.
    Simulates instantaneous USSD authorization and auto-success.
    """
    def initiate_payment(self, transaction_id: str, phone_number: str, amount_xaf: int) -> dict:
        logger.info(f"[MOCK PAYMENT] Initiated transaction {transaction_id} for {phone_number} of amount {amount_xaf} XAF")
        return {
            "success": True,
            "reference_id": f"MOCK-{transaction_id[:8]}",
            "status": "success",
            "message": "Paiement simulé avec succès en mode démo."
        }

    def check_status(self, reference_id: str) -> dict:
        return {"status": "success", "raw": {"mock": True}}
