import os
from pathlib import Path
import dj_database_url

# بناء المسارات داخل المشروع
BASE_DIR = Path(__file__).resolve().parent.parent

# --- إعدادات الأمان والبيئة ---
# السكرت كي يقرأ من .env أو يستخدم قيمة افتراضية للتطوير
SECRET_KEY = os.getenv('DJANGO_SECRET_KEY', 'django-insecure-agro-tech-2026-key')

# تفعيل الـ Debug في التطوير وتعطيله في الإنتاج بناءً على .env
DEBUG = os.getenv('DJANGO_DEBUG', 'True') == 'True'

# السماح لجميع المضيفين (مهم جداً لعمل Codespace بدون مشاكل)
ALLOWED_HOSTS = ['*', '.githubpreview.dev', 'localhost', '127.0.0.1']

# --- تطبيقات AGRO_TECH المتفق عليها ---
INSTALLED_APPS = [
    'django.contrib.admin',
    'django.contrib.auth',
    'django.contrib.contenttypes',
    'django.contrib.sessions',
    'django.contrib.messages',
    'django.contrib.staticfiles',
    'django.contrib.gis',          # تفعيل نظام المعلومات الجغرافي (PostGIS)
    'rest_framework',              # لإدارة الـ APIs
    'rest_framework_gis',          # لدعم البيانات الجغرافية في الـ API
    'geo_engine.apps.GeoEngineConfig', 
MIDDLEWARE = [
    'django.middleware.security.SecurityMiddleware',
    'whitenoise.middleware.WhiteNoiseMiddleware',  # لخدمة الملفات الساكنة بكفاءة
    'django.contrib.sessions.middleware.SessionMiddleware',
    'django.middleware.common.CommonMiddleware',
    'django.middleware.csrf.CsrfViewMiddleware',
    'django.contrib.auth.middleware.AuthenticationMiddleware',
    'django.contrib.messages.middleware.MessageMiddleware',
    'django.middleware.clickjacking.XFrameOptionsMiddleware',
]

ROOT_URLCONF = 'core.urls'

TEMPLATES = [
    {
        'BACKEND': 'django.template.backends.django.DjangoTemplates',
        'DIRS': [],
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

WSGI_APPLICATION = 'core.wsgi.application'

# --- قاعدة البيانات الجغرافية (PostGIS) ---
# تعتمد على المتغير DATABASE_URL من ملف .env لضمان السيادة
DATABASES = {
    'default': dj_database_url.config(
        default=os.getenv('DATABASE_URL'),
        engine='django.contrib.gis.db.backends.postgis'
    )
}

# --- إعدادات Hugging Face و LanceDB (المحرك الذكي المتفق عليه) ---
HF_TOKEN = os.getenv('HF_TOKEN')
LANCEDB_URI = os.getenv('LANCEDB_URI', 'hf://agrotech26/Agro-Brain-Db')

# --- مسارات المكتبات الجغرافية (مهمة جداً لـ Docker) ---
GDAL_LIBRARY_PATH = os.getenv('GDAL_LIBRARY_PATH', '/usr/lib/libgdal.so')
GEOS_LIBRARY_PATH = os.getenv('GEOS_LIBRARY_PATH', '/usr/lib/libgeos_c.so')

# --- التحقق من كلمة المرور ---
AUTH_PASSWORD_VALIDATORS = [
    {'NAME': 'django.contrib.auth.password_validation.UserAttributeSimilarityValidator'},
    {'NAME': 'django.contrib.auth.password_validation.MinimumLengthValidator'},
    {'NAME': 'django.contrib.auth.password_validation.CommonPasswordValidator'},
    {'NAME': 'django.contrib.auth.password_validation.NumericPasswordValidator'},
]

# --- تدويل المشروع (اللغة والوقت) ---
LANGUAGE_CODE = 'ar-dz'  # اللغة العربية (الجزائر)
TIME_ZONE = 'Africa/Algiers'
USE_I18N = True
USE_TZ = True

# --- الملفات الساكنة والمرفوعات ---
STATIC_URL = 'static/'
STATIC_ROOT = BASE_DIR / 'staticfiles'

# استخدام WhiteNoise لضغط الملفات الساكنة وخدمتها بسرعة
STATICFILES_STORAGE = 'whitenoise.storage.CompressedManifestStaticFilesStorage'

DEFAULT_AUTO_FIELD = 'django.db.models.BigAutoField'