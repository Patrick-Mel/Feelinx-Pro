from django.urls import path
from .views import (
    MyProfileView, PhotoUploadView, PhotoDetailView, PhotoReorderView,
    PreferenceView, PersonalityQuizView, ProfileStatsView, PublicProfileDetailView,
    VerifyProfileView
)

urlpatterns = [
    path('me/', MyProfileView.as_view(), name='profile-me'),
    path('me/photos/', PhotoUploadView.as_view(), name='profile-photo-upload'),
    path('me/photos/<uuid:photo_id>/', PhotoDetailView.as_view(), name='profile-photo-delete'),
    path('me/photos/reorder/', PhotoReorderView.as_view(), name='profile-photo-reorder'),
    path('me/preferences/', PreferenceView.as_view(), name='profile-preferences'),
    path('me/personality/', PersonalityQuizView.as_view(), name='profile-personality'),
    path('me/stats/', ProfileStatsView.as_view(), name='profile-stats'),
    path('me/verify/', VerifyProfileView.as_view(), name='profile-verify'),
    path('<uuid:profile_id>/', PublicProfileDetailView.as_view(), name='profile-detail'),
]

