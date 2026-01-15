# المرحلة 1: البناء (المصنع الثقيل)
FROM python:3.12-slim-bookworm AS builder
WORKDIR /app

ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    g++ gcc cmake \
    libgdal-dev libgeos-dev libproj-dev \
    libpq-dev pkg-config \
    && rm -rf /var/lib/apt/lists/*

RUN pip install --upgrade pip setuptools wheel

# تثبيت المكونات الجغرافية الأساسية
RUN pip install --no-cache-dir numpy==1.26.4 pandas==2.2.1
RUN pip install --no-cache-dir Fiona==1.9.5 Shapely==2.0.3

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# --- المرحلة 2: التشغيل (الحاوية الخفيفة والذكية) ---
FROM python:3.12-slim-bookworm
WORKDIR /app

# تعريف بوابات الاستلام (24 بوابة) لربط السحاب
# نركز هنا على أهم المتغيرات التي يحتاجها النظام وقت البناء والتشغيل
ARG DJANGO_SECRET_KEY
ARG HF_TOKEN
ARG SH_CLIENT_ID
ARG SH_CLIENT_SECRET
ARG REDIS_URL
ARG DATABASE_URL
ARG R2_BUCKET_NAME
ARG R2_ENDPOINT
ARG MAILERSEND_USERNAME
ARG WAPOR_API_KEY
# تحويل الـ ARGs إلى ENVs لتراها لغة Python
ENV DJANGO_SECRET_KEY=$DJANGO_SECRET_KEY
ENV HF_TOKEN=$HF_TOKEN
ENV SH_CLIENT_ID=$SH_CLIENT_ID
ENV SH_CLIENT_SECRET=$SH_CLIENT_SECRET
ENV REDIS_URL=$REDIS_URL
ENV DATABASE_URL=$DATABASE_URL
ENV R2_BUCKET_NAME=$R2_BUCKET_NAME \
    R2_ENDPOINT=$R2_ENDPOINT \
    MAILERSEND_USERNAME=$MAILERSEND_USERNAME \
    WAPOR_API_KEY=$WAPOR_API_KEY
# تثبيت مكتبات التشغيل فقط (Runtime Libraries)
RUN apt-get update && apt-get install -y --no-install-recommends \
    libgdal32 libgeos-c1v5 libproj25 libpq5 postgresql-client \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# نسخ المكتبات المثبتة من مرحلة البناء
COPY --from=builder /usr/local/lib/python3.12/site-packages /usr/local/lib/python3.12/site-packages
COPY --from=builder /usr/local/bin /usr/local/bin
COPY . .

# المسارات الجغرافية (هذا هو OS الذي اتفقنا عليه)
ENV GDAL_LIBRARY_PATH=/usr/lib/libgdal.so
ENV GEOS_LIBRARY_PATH=/usr/lib/libgeos_c.so

# تشغيل خادم AGRO_TECH
CMD ["python", "manage.py", "runserver", "0.0.0.0:8000"]