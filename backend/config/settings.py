import os
from pathlib import Path
from datetime import timedelta

BASE_DIR = Path(__file__).resolve().parent.parent

# Add apps folder to sys.path
import sys
sys.path.insert(0, str(BASE_DIR / 'apps'))

def env_bool(name, default=False):
    val = os.environ.get(name, str(default))
    return val.lower() in ('true', '1', 't', 'yes')

def env_list(name, default=None):
    val = os.environ.get(name, '')
    if not val:
        return default or []
    return [x.strip() for x in val.split(',')]

SECRET_KEY = os.environ.get('SECRET_KEY', 'django-insecure-feelinx-dev-secret-key-change-in-production-12345')
DEBUG = env_bool('DEBUG', True)
ALLOWED_HOSTS = env_list('ALLOWED_HOSTS', ['*'])

CSRF_TRUSTED_ORIGINS = env_list('CSRF_TRUSTED_ORIGINS', [
    'https://*.up.railway.app',
    'https://feelinx-backend-production-9537.up.railway.app',
    'http://localhost:8000',
    'http://127.0.0.1:8000',
])

SECURE_PROXY_SSL_HEADER = ('HTTP_X_FORWARDED_PROTO', 'https')



INSTALLED_APPS = []

try:
    import daphne
    INSTALLED_APPS.append('daphne')
except ImportError:
    pass

INSTALLED_APPS += [
    'jazzmin',
    'django.contrib.admin',
    'django.contrib.auth',
    'django.contrib.contenttypes',
    'django.contrib.sessions',
    'django.contrib.messages',
    'django.contrib.staticfiles',


    # Third party apps
    'rest_framework',
    'rest_framework_simplejwt',
    'rest_framework_simplejwt.token_blacklist',
    'corsheaders',
    'channels',
    'django_filters',
    'drf_spectacular',

    # Local Feelinx apps
    'apps.accounts',
    'apps.profiles',
    'apps.discovery',
    'apps.chat',
    'apps.payments',
    'apps.safety',
    'apps.notifications',
    'apps.common',
]

MIDDLEWARE = [
    'corsheaders.middleware.CorsMiddleware',
    'django.middleware.security.SecurityMiddleware',
    'whitenoise.middleware.WhiteNoiseMiddleware',
    'django.contrib.sessions.middleware.SessionMiddleware',
    'django.middleware.locale.LocaleMiddleware',
    'django.middleware.common.CommonMiddleware',
    'django.middleware.csrf.CsrfViewMiddleware',
    'django.contrib.auth.middleware.AuthenticationMiddleware',
    'django.contrib.messages.middleware.MessageMiddleware',
    'django.middleware.clickjacking.XFrameOptionsMiddleware',
]

ROOT_URLCONF = 'config.urls'

TEMPLATES = [
    {
        'BACKEND': 'django.template.backends.django.DjangoTemplates',
        'DIRS': [BASE_DIR / 'templates'],
        'APP_DIRS': True,
        'OPTIONS': {
            'context_processors': [
                'django.template.context_processors.debug',
                'django.template.context_processors.request',
                'django.contrib.auth.context_processors.auth',
                'django.contrib.messages.context_processors.messages',
            ],
        },
    },
]

WSGI_APPLICATION = 'config.wsgi.application'
ASGI_APPLICATION = 'config.asgi.application'

# Database configuration: Force 100% PostgreSQL (SQLite completely removed)
import dj_database_url

db_url = (
    os.environ.get('DATABASE_URL') or
    os.environ.get('POSTGRES_URL') or
    os.environ.get('DATABASE_PRIVATE_URL') or
    os.environ.get('RAILWAY_DATABASE_URL')
)

if db_url:
    DATABASES = {
        'default': dj_database_url.parse(
            db_url,
            conn_max_age=600,
            conn_health_checks=True,
        )
    }
else:
    DATABASES = {
        'default': {
            'ENGINE': 'django.db.backends.postgresql',
            'NAME': os.environ.get('PGDATABASE') or os.environ.get('DB_NAME', 'postgres'),
            'USER': os.environ.get('PGUSER') or os.environ.get('DB_USER', 'postgres'),
            'PASSWORD': os.environ.get('PGPASSWORD') or os.environ.get('DB_PASSWORD', 'postgres'),
            'HOST': os.environ.get('PGHOST') or os.environ.get('DB_HOST', 'localhost'),
            'PORT': os.environ.get('PGPORT') or os.environ.get('DB_PORT', '5432'),
        }
    }




AUTH_USER_MODEL = 'accounts.User'

AUTH_PASSWORD_VALIDATORS = [
    {'NAME': 'django.contrib.auth.password_validation.UserAttributeSimilarityValidator'},
    {'NAME': 'django.contrib.auth.password_validation.MinimumLengthValidator'},
    {'NAME': 'django.contrib.auth.password_validation.CommonPasswordValidator'},
    {'NAME': 'django.contrib.auth.password_validation.NumericPasswordValidator'},
]

LANGUAGE_CODE = 'fr'
TIME_ZONE = 'Africa/Douala'
USE_I18N = True
USE_TZ = True

LANGUAGES = [
    ('fr', 'Français 🇫🇷'),
    ('en', 'English 🇬🇧'),
]

STATIC_URL = '/static/'
STATIC_ROOT = BASE_DIR / 'staticfiles'
MEDIA_URL = '/media/'
MEDIA_ROOT = BASE_DIR / 'media'

DEFAULT_AUTO_FIELD = 'django.db.models.BigAutoField'

# REST Framework Settings
REST_FRAMEWORK = {
    'DEFAULT_AUTHENTICATION_CLASSES': (
        'rest_framework_simplejwt.authentication.JWTAuthentication',
    ),
    'DEFAULT_PERMISSION_CLASSES': (
        'rest_framework.permissions.IsAuthenticated',
    ),
    'DEFAULT_FILTER_BACKENDS': (
        'django_filters.rest_framework.DjangoFilterBackend',
        'rest_framework.filters.SearchFilter',
        'rest_framework.filters.OrderingFilter',
    ),
    'DEFAULT_PAGINATION_CLASS': 'rest_framework.pagination.CursorPagination',
    'PAGE_SIZE': 20,
    'DEFAULT_SCHEMA_CLASS': 'drf_spectacular.openapi.AutoSchema',
}

# SimpleJWT Settings
SIMPLE_JWT = {
    'ACCESS_TOKEN_LIFETIME': timedelta(minutes=60),
    'REFRESH_TOKEN_LIFETIME': timedelta(days=30),
    'ROTATE_REFRESH_TOKENS': True,
    'BLACKLIST_AFTER_ROTATION': True,
    'UPDATE_LAST_LOGIN': True,
    'ALGORITHM': 'HS256',
    'SIGNING_KEY': SECRET_KEY,
    'AUTH_HEADER_TYPES': ('Bearer',),
}

# OpenAPI OpenAPI Spec Settings
SPECTACULAR_SETTINGS = {
    'TITLE': 'Feelinx API',
    'DESCRIPTION': 'API backend pour l\'application de rencontre Feelinx (Afrique / Cameroun)',
    'VERSION': '1.0.0',
    'SERVE_INCLUDE_SCHEMA': False,
}

# Django Channels Settings
REDIS_URL = os.environ.get('REDIS_URL', 'redis://localhost:6379/0')
CHANNEL_LAYERS = {
    'default': {
        'BACKEND': 'channels_redis.core.RedisChannelLayer',
        'CONFIG': {
            "hosts": [REDIS_URL],
        },
    },
}

# Celery Configuration
CELERY_BROKER_URL = REDIS_URL
CELERY_RESULT_BACKEND = REDIS_URL
CELERY_ACCEPT_CONTENT = ['json']
CELERY_TASK_SERIALIZER = 'json'
CELERY_RESULT_SERIALIZER = 'json'
CELERY_TIMEZONE = TIME_ZONE

# CORS Configuration
CORS_ALLOW_ALL_ORIGINS = True
CORS_ALLOW_CREDENTIALS = True

# SMS & Service Providers Settings
SMS_PROVIDER = os.environ.get('SMS_PROVIDER', 'console')
TWILIO_ACCOUNT_SID = os.environ.get('TWILIO_ACCOUNT_SID', '')
TWILIO_AUTH_TOKEN = os.environ.get('TWILIO_AUTH_TOKEN', '')
TWILIO_PHONE_NUMBER = os.environ.get('TWILIO_PHONE_NUMBER', '')
NEXAH_API_KEY = os.environ.get('NEXAH_API_KEY', '')
NEXAH_SENDER_ID = os.environ.get('NEXAH_SENDER_ID', 'FEELINX')

ONESIGNAL_APP_ID = os.environ.get('ONESIGNAL_APP_ID', 'mock-onesignal-app-id')
ONESIGNAL_REST_API_KEY = os.environ.get('ONESIGNAL_REST_API_KEY', 'mock-onesignal-api-key')

# Mobile Money Settings
MTN_MOMO_PRIMARY_KEY = os.environ.get('MTN_MOMO_PRIMARY_KEY', '')
MTN_MOMO_SECONDARY_KEY = os.environ.get('MTN_MOMO_SECONDARY_KEY', '')
MTN_MOMO_USER_ID = os.environ.get('MTN_MOMO_USER_ID', '')
MTN_MOMO_API_SECRET = os.environ.get('MTN_MOMO_API_SECRET', '')
MTN_MOMO_TARGET_ENV = os.environ.get('MTN_MOMO_TARGET_ENV', 'sandbox')

ORANGE_MONEY_CLIENT_ID = os.environ.get('ORANGE_MONEY_CLIENT_ID', '')
ORANGE_MONEY_CLIENT_SECRET = os.environ.get('ORANGE_MONEY_CLIENT_SECRET', '')
ORANGE_MONEY_MERCHANT_KEY = os.environ.get('ORANGE_MONEY_MERCHANT_KEY', '')
ORANGE_MONEY_ENV = os.environ.get('ORANGE_MONEY_ENV', 'sandbox')

AUTHENTICATION_BACKENDS = [
    'apps.accounts.backends.PhoneBackend',
    'django.contrib.auth.backends.ModelBackend',
]

# Jazzmin Modern Django Admin Theme Settings
JAZZMIN_SETTINGS = {
    "site_title": "Feelinx Admin",
    "site_header": "Feelinx Pro",
    "site_brand": "Feelinx Control Center",
    "site_logo_classes": "img-circle",
    "welcome_sign": "Bienvenue sur le centre de contrôle Feelinx",
    "copyright": "Feelinx Ltd",

    "search_model": ["profiles.Profile", "accounts.User"],
    "topmenu_links": [
        {"name": "Tableau de Bord", "url": "admin:index", "permissions": ["auth.view_user"]},
        {"name": "Documentation Swagger API", "url": "/api/docs/", "new_window": True},
    ],
    "show_sidebar": True,
    "navigation_expanded": True,
    "icons": {
        "accounts.User": "fas fa-user-shield",
        "accounts.OTPCode": "fas fa-key",
        "profiles.Profile": "fas fa-user-circle",
        "profiles.Photo": "fas fa-camera",
        "profiles.Interest": "fas fa-tags",
        "discovery.Swipe": "fas fa-fire",
        "discovery.Match": "fas fa-heart",
        "discovery.ProfileView": "fas fa-eye",
        "chat.Conversation": "fas fa-comments",
        "chat.Message": "fas fa-paper-plane",
        "payments.Plan": "fas fa-gem",
        "payments.Subscription": "fas fa-crown",
        "payments.Transaction": "fas fa-credit-card",
        "safety.Report": "fas fa-shield-alt",
        "safety.Block": "fas fa-user-slash",
    },
    "default_icon_parents": "fas fa-chevron-circle-right",
    "default_icon_children": "fas fa-circle",
    "related_modal_active": True,
    "use_google_fonts_boilerplates": True,
    "changeform_format": "horizontal_tabs",
    "language_chooser": True,
    "show_ui_builder": True,
    "show_theme_chooser": True,
}

JAZZMIN_UI_TWEAKS = {
    "navbar_small_text": False,
    "footer_small_text": False,
    "body_small_text": False,
    "brand_small_text": False,
    "brand_colour": "navbar-dark",
    "accent": "accent-primary",
    "navbar": "navbar-dark navbar-primary",
    "no_navbar_border": False,
    "navbar_fixed": True,
    "layout_boxed": False,
    "footer_fixed": False,
    "sidebar_fixed": True,
    "sidebar": "sidebar-dark-primary",
    "sidebar_nav_small_text": False,
    "theme": "darkly",
    "default_theme_mode": "dark",
    "button_classes": {
        "primary": "btn-primary",
        "secondary": "btn-secondary",
        "info": "btn-info",
        "warning": "btn-warning",
        "danger": "btn-danger",
        "success": "btn-success"
    }
}



