from django.urls import path
from rest_framework_simplejwt.views import TokenRefreshView
from .views import RequestOTPView, VerifyOTPView, LogoutView, DeleteAccountView

urlpatterns = [
    path('request-otp/', RequestOTPView.as_view(), name='auth-request-otp'),
    path('verify-otp/', VerifyOTPView.as_view(), name='auth-verify-otp'),
    path('refresh/', TokenRefreshView.as_view(), name='auth-token-refresh'),
    path('logout/', LogoutView.as_view(), name='auth-logout'),
    path('account/', DeleteAccountView.as_view(), name='auth-delete-account'),
]
