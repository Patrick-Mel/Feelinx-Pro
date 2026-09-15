from rest_framework.views import exception_handler
from rest_framework.response import Response
from rest_framework import status

def custom_exception_handler(exc, context):
    response = exception_handler(exc, context)

    if response is not None:
        custom_response_data = {
            "success": False,
            "status_code": response.status_code,
            "error": {
                "message": "Une erreur est survenue.",
                "details": response.data
            }
        }
        
        if response.status_code == 401:
            custom_response_data["error"]["message"] = "Session expirée ou non autorisée."
        elif response.status_code == 403:
            custom_response_data["error"]["message"] = "Accès refusé."
        elif response.status_code == 404:
            custom_response_data["error"]["message"] = "Ressource introuvable."
        elif response.status_code == 429:
            custom_response_data["error"]["message"] = "Trop de requêtes. Veuillez réessayer plus tard."

        response.data = custom_response_data

    return response
