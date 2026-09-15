from django.contrib import admin
from django.urls import path, include
from django.conf import settings
from django.conf.urls.static import static
from drf_spectacular.views import SpectacularAPIView, SpectacularSwaggerView

urlpatterns = [
    path('i18n/', include('django.conf.urls.i18n')),
    path('admin/', admin.site.urls),
    
    # OpenAPI Documentation
    path('api/schema/', SpectacularAPIView.as_view(), name='schema'),
    path('api/docs/', SpectacularSwaggerView.as_view(url_name='schema'), name='swagger-ui'),

    # API v1 endpoints
    path('api/v1/auth/', include('apps.accounts.urls')),
    path('api/v1/profiles/', include('apps.profiles.urls')),
    path('api/v1/discovery/', include('apps.discovery.urls')),
    path('api/v1/matches/', include('apps.discovery.urls_matches')),
    path('api/v1/chat/', include('apps.chat.urls')),
    path('api/v1/payments/', include('apps.payments.urls')),
    path('api/v1/safety/', include('apps.safety.urls')),
    path('api/v1/notifications/', include('apps.notifications.urls')),
    path('api/v1/interests/', include('apps.profiles.urls_interests')),
]

if settings.DEBUG:
    urlpatterns += static(settings.MEDIA_URL, document_root=settings.MEDIA_ROOT)
    urlpatterns += static(settings.STATIC_URL, document_root=settings.STATIC_ROOT)
