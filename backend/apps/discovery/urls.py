from django.urls import path
from .views import FeedView, SwipeView, RewindView, BoostView, LikesReceivedView

urlpatterns = [
    path('feed/', FeedView.as_view(), name='discovery-feed'),
    path('swipe/', SwipeView.as_view(), name='discovery-swipe'),
    path('rewind/', RewindView.as_view(), name='discovery-rewind'),
    path('boost/', BoostView.as_view(), name='discovery-boost'),
    path('likes-received/', LikesReceivedView.as_view(), name='discovery-likes-received'),
]
