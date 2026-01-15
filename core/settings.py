import os
from pathlib import Path
import dj_database_url

# بناء المسارات داخل المشروع
BASE_DIR = Path(__file__).resolve().parent.parent

# --- 1. إعدادات الأمان والبيئة الأساسية ---
SECRET_KEY = os.getenv('DJANGO_SECRET_KEY', 'django-insecure-agro-tech-2026-key')
DEBUG = os.getenv('DJANGO_DEBUG', 'True') == 'True'
ALLOWED_HOSTS = os.getenv('ALLOWED_HOSTS', 'localhost,127.0.0.1,.githubpreview.dev').split(',')

# --- 2. تطبيقات AGRO_TECH (نظام المعلومات الجغرافي والذكاء الاصطناعي) ---
INSTALLED_APPS = [
    'django.contrib.admin',
    'django.contrib.auth',
    'django.contrib.contenttypes',
    'django.contrib.sessions',
    'django.contrib.messages',
    'django.contrib.staticfiles',
    'django.contrib.gis',           # تفعيل PostGIS
    'rest_framework',
    'rest_framework_gis',
    'geo_engine.apps.GeoEngineConfig', 
]

MIDDLEWARE = [
    'django.middleware.security.SecurityMiddleware',
    'whitenoise.middleware.WhiteNoiseMiddleware',
    'django.contrib.sessions.middleware.SessionMiddleware',
    'django.middleware.common.CommonMiddleware',
    'django.middleware.csrf.CsrfViewMiddleware',
    'django.contrib.auth.middleware.AuthenticationMiddleware',
    'django.contrib.messages.middleware.MessageMiddleware',
    'django.middleware.clickjacking.XFrameOptionsMiddleware',
]

ROOT_URLCONF = 'core.urls'
WSGI_APPLICATION = 'core.wsgi.application'

# --- 3. قاعدة البيانات الجغرافية (السيادة على البيانات) ---
DATABASES = {
    'default': dj_database_url.config(
        default=os.getenv('DATABASE_URL'),
        engine='django.contrib.gis.db.backends.postgis'
    )
}

# --- 4. محركات الأقمار الصناعية (Sentinel & FAO) ---
SH_CLIENT_ID = os.getenv('SH_CLIENT_ID')
SH_CLIENT_SECRET = os.getenv('SH_CLIENT_SECRET')
SH_INSTANCE_ID = os.getenv('SH_INSTANCE_ID')
FAO_API_KEY = os.getenv('FAO_API_KEY')
WAPOR_API_KEY = os.getenv('WAPOR_API_KEY')
GOOGLE_MAPS_API_KEY = os.getenv('GOOGLE_MAPS_API_KEY')

# --- 5. الذكاء الاصطناعي وقواعد بيانات المتجهات ---
HF_TOKEN = os.getenv('HF_TOKEN')
LANCEDB_URI = os.getenv('LANCEDB_URI', 'hf://agrotech26/Agro-Brain-Db')
MODAL_TOKEN_ID = os.getenv('MODAL_TOKEN_ID')
MODAL_TOKEN_SECRET = os.getenv('MODAL_TOKEN_SECRET')

# --- 6. التخزين والأداء (R2 & Redis) ---
R2_ACCESS_KEY = os.getenv('R2_ACCESS_KEY')
R2_SECRET_KEY = os.getenv('R2_SECRET_KEY')
R2_BUCKET_NAME = os.getenv('R2_BUCKET_NAME')
R2_ENDPOINT = os.getenv('R2_ENDPOINT')
REDIS_URL = os.getenv('REDIS_URL')
REDIS_TOKEN = os.getenv('REDIS_TOKEN')

# --- 7. مسارات المكتبات الجغرافية (مهم جداً للـ Docker) ---
GDAL_LIBRARY_PATH = os.getenv('GDAL_LIBRARY_PATH', '/usr/lib/libgdal.so')
GEOS_LIBRARY_PATH = os.getenv('GEOS_LIBRARY_PATH', '/usr/lib/libgeos_c.so')

# --- 8. التدويل (اللغة والوقت - ورقلة، الجزائر) ---
LANGUAGE_CODE = 'ar-dz'
TIME_ZONE = 'Africa/Algiers'
USE_I18N = True
USE_TZ = True

# --- 9. الملفات الساكنة ---
STATIC_URL = 'static/'
STATIC_ROOT = BASE_DIR / 'staticfiles'
STATICFILES_STORAGE = 'whitenoise.storage.CompressedManifestStaticFilesStorage'

DEFAULT_AUTO_FIELD = 'django.db.models.BigAutoField'
# --- 10. التنبيهات والتواصل (Firebase & MailerSend) ---
FIREBASE_CONFIG_PATH = os.getenv('FIREBASE_CONFIG_PATH')
FIREBASE_MESSAGING_ID = os.getenv('FIREBASE_MESSAGING_ID')

MAILERSEND_API_KEY = os.getenv('MAILERSEND_API_KEY')
MAILERSEND_USERNAME = os.getenv('MAILERSEND_USERNAME')

# إعدادات البريد الإلكتروني في جانجو لاستخدام MailerSend (عن طريق SMTP أو API)
EMAIL_BACKEND = 'django.core.mail.backends.smtp.EmailBackend'
EMAIL_HOST = 'smtp.mailersend.net'
EMAIL_PORT = 587
EMAIL_USE_TLS = True
EMAIL_HOST_USER = os.getenv('MAILERSEND_USERNAME') # غالباً يكون إيميلك المسجل
EMAIL_HOST_PASSWORD = os.getenv('MAILERSEND_API_KEY')

# قوالب العرض (Templates)
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