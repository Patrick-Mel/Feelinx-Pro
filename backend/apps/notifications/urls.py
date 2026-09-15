from django.urls import path
from .views import DeviceTokenView, NotificationListView, MarkNotificationReadView

urlpatterns = [
    path('device-token/', DeviceTokenView.as_view(), name='notifications-device-token'),
    path('', NotificationListView.as_view(), name='notifications-list'),
    path('<uuid:notification_id>/read/', MarkNotificationReadView.as_view(), name='notifications-read'),
]
