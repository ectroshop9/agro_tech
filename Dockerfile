# --- المرحلة 1: البناء (المصنع الثقيل) ---
FROM python:3.12-slim-bookworm AS builder
WORKDIR /app

ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential g++ gcc cmake \
    libgdal-dev libgeos-dev libproj-dev \
    libpq-dev pkg-config \
    && rm -rf /var/lib/apt/lists/*

RUN pip install --upgrade pip setuptools wheel
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# --- المرحلة 2: التشغيل (الحاوية الخفيفة والذكية) ---
FROM python:3.12-slim-bookworm
WORKDIR /app

# 1. استلام كافة المتغيرات (ARGs) من GitHub Actions أو Docker Compose
ARG DJANGO_SECRET_KEY
ARG DATABASE_URL
ARG SH_CLIENT_ID
ARG SH_CLIENT_SECRET
ARG SH_INSTANCE_ID
ARG GOOGLE_MAPS_API_KEY
ARG FAO_API_KEY
ARG HF_TOKEN
ARG LANCEDB_URI
ARG MODAL_TOKEN_ID
ARG MODAL_TOKEN_SECRET
ARG R2_ACCESS_KEY
ARG R2_SECRET_KEY
ARG R2_BUCKET_NAME
ARG R2_ENDPOINT
ARG REDIS_URL
ARG REDIS_TOKEN
ARG FIREBASE_CONFIG_PATH
ARG MAILERSEND_API_KEY
ARG MAILERSEND_USERNAME
ARG WAPOR_API_KEY
ARG JITSI_DOMAIN

# 2. تحويل الـ ARGs إلى ENVs (ليقرأها Django)
ENV DJANGO_SECRET_KEY=$DJANGO_SECRET_KEY \
    DATABASE_URL=$DATABASE_URL \
    SH_CLIENT_ID=$SH_CLIENT_ID \
    SH_CLIENT_SECRET=$SH_CLIENT_SECRET \
    SH_INSTANCE_ID=$SH_INSTANCE_ID \
    GOOGLE_MAPS_API_KEY=$GOOGLE_MAPS_API_KEY \
    FAO_API_KEY=$FAO_API_KEY \
    HF_TOKEN=$HF_TOKEN \
    LANCEDB_URI=$LANCEDB_URI \
    MODAL_TOKEN_ID=$MODAL_TOKEN_ID \
    MODAL_TOKEN_SECRET=$MODAL_TOKEN_SECRET \
    R2_ACCESS_KEY=$R2_ACCESS_KEY \
    R2_SECRET_KEY=$R2_SECRET_KEY \
    R2_BUCKET_NAME=$R2_BUCKET_NAME \
    R2_ENDPOINT=$R2_ENDPOINT \
    REDIS_URL=$REDIS_URL \
    REDIS_TOKEN=$REDIS_TOKEN \
    FIREBASE_CONFIG_PATH=$FIREBASE_CONFIG_PATH \
    MAILERSEND_API_KEY=$MAILERSEND_API_KEY \
    MAILERSEND_USERNAME=$MAILERSEND_USERNAME \
    WAPOR_API_KEY=$WAPOR_API_KEY \
    JITSI_DOMAIN=$JITSI_DOMAIN

# 3. تثبيت مكتبات التشغيل الجغرافية
RUN apt-get update && apt-get install -y --no-install-recommends \
    libgdal32 libgeos-c1v5 libproj25 libpq5 postgresql-client \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# 4. نسخ الملفات والمكتبات
COPY --from=builder /usr/local/lib/python3.12/site-packages /usr/local/lib/python3.12/site-packages
COPY --from=builder /usr/local/bin /usr/local/bin
COPY . .

# 5. ضبط المسارات الجغرافية لنظام Debian/Ubuntu
ENV GDAL_LIBRARY_PATH=/usr/lib/libgdal.so
ENV GEOS_LIBRARY_PATH=/usr/lib/libgeos_c.so

CMD ["python", "manage.py", "runserver", "0.0.0.0:8000"]