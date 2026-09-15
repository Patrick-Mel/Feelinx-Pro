from django.urls import path
from .views import (
    VerificationUploadView, VerificationStatusView, ReportCreateView,
    BlockListCreateView, UnblockView
)

urlpatterns = [
    path('verification/', VerificationUploadView.as_view(), name='safety-verification-upload'),
    path('verification/status/', VerificationStatusView.as_view(), name='safety-verification-status'),
    path('reports/', ReportCreateView.as_view(), name='safety-reports'),
    path('blocks/', BlockListCreateView.as_view(), name='safety-blocks-list-create'),
    path('blocks/<uuid:block_id>/', UnblockView.as_view(), name='safety-unblock'),
]
