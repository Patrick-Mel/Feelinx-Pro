from django.urls import path
from rest_framework_simplejwt.views import TokenRefreshView
from .views import (
    RequestOTPView, VerifyOTPView, PasswordLoginView, 
    RegisterWithPasswordView, ResetPasswordConfirmView, 
    LogoutView, DeleteAccountView
)

urlpatterns = [
    path('request-otp/', RequestOTPView.as_view(), name='auth-request-otp'),
    path('verify-otp/', VerifyOTPView.as_view(), name='auth-verify-otp'),
    path('login/', PasswordLoginView.as_view(), name='auth-password-login'),
    path('register/', RegisterWithPasswordView.as_view(), name='auth-password-register'),
    path('reset-password/confirm/', ResetPasswordConfirmView.as_view(), name='auth-reset-password-confirm'),
    path('refresh/', TokenRefreshView.as_view(), name='auth-token-refresh'),
    path('logout/', LogoutView.as_view(), name='auth-logout'),
    path('account/', DeleteAccountView.as_view(), name='auth-delete-account'),
]
