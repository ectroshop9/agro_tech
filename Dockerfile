# المرحلة 1: البناء
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

# تثبيت المكونات الأساسية المضمونة
RUN pip install --no-cache-dir numpy==1.26.4 pandas==2.2.1
RUN pip install --no-cache-dir Fiona==1.9.5 Shapely==2.0.3

COPY requirements.txt .

# تثبيت ما تبقى (بدون المكتبة التي سببت الفشل)
RUN pip install --no-cache-dir -r requirements.txt

# المرحلة 2: التشغيل
FROM python:3.12-slim-bookworm
WORKDIR /app

RUN apt-get update && apt-get install -y --no-install-recommends \
    libgdal32 libgeos-c1v5 libproj25 libpq5 postgresql-client \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

COPY --from=builder /usr/local/lib/python3.12/site-packages /usr/local/lib/python3.12/site-packages
COPY --from=builder /usr/local/bin /usr/local/bin
COPY . .

ENV GDAL_LIBRARY_PATH=/usr/lib/libgdal.so
ENV GEOS_LIBRARY_PATH=/usr/lib/libgeos_c.so

CMD ["python", "manage.py", "runserver", "0.0.0.0:8000"]