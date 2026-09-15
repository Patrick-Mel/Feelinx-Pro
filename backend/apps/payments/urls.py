from django.urls import path
from .views import (
    PlanListView, SubscribeView, TransactionStatusView,
    MTNWebhookView, OrangeWebhookView, SubscriptionDetailView, CancelSubscriptionView
)

urlpatterns = [
    path('plans/', PlanListView.as_view(), name='payments-plans'),
    path('subscribe/', SubscribeView.as_view(), name='payments-subscribe'),
    path('transactions/<uuid:transaction_id>/', TransactionStatusView.as_view(), name='payments-transaction-status'),
    path('webhook/mtn/', MTNWebhookView.as_view(), name='payments-webhook-mtn'),
    path('webhook/orange/', OrangeWebhookView.as_view(), name='payments-webhook-orange'),
    path('subscription/', SubscriptionDetailView.as_view(), name='payments-subscription'),
    path('subscription/cancel/', CancelSubscriptionView.as_view(), name='payments-subscription-cancel'),
]
