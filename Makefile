# ==========================================
# 🚀 AGRO_TECH - نظام التحكم السيادي الشامل
# ==========================================
SHELL := /bin/bash

# --- الإعدادات الشخصية (تعديل لمرة واحدة) ---
GH_USER := ectroshop9
GH_REPO := agro_tech
CONTAINER_NAME := agro_web_app

# تحويل آلي للحروف الصغيرة لضمان عمل Docker Registry بدون أخطاء
LOW_USER := $(shell echo $(GH_USER) | tr '[:upper:]' '[:lower:]')
LOW_REPO := $(shell echo $(GH_REPO) | tr '[:upper:]' '[:lower:]')
IMAGE_URL := ghcr.io/$(LOW_USER)/$(LOW_REPO)

# الألوان للتنظيم البصري
CYAN  := \033[1;36m
GREEN := \033[1;32m
YELLOW:= \033[1;33m
RED   := \033[1;31m
NC    := \033[0m

.PHONY: help build up down restart mm migrate worker sh logs ps size clean destroy save list_imgs remove_img publish

# المساعدة - عرض خريطة التحكم الشاملة
help:
	@echo -e "$(CYAN)قائمة التحكم بمشروع AGRO_TECH (النسخة الكاملة):$(NC)"
	@echo -e "--------------------------------------------------"
	@echo -e "$(GREEN)إدارة Docker والرفع السحابي:$(NC)"
	@echo "  make build      - بناء الحاويات وحقن المكتبات الجغرافية"
	@echo "  make up         - تشغيل المشروع في الخلفية"
	@echo "  make stop       - إيقاف الخدمات مؤقتاً"
	@echo "  make publish    - [حفظ + رفع] مباشر إلى GitHub (أمر واحد)"
	@echo "  make save       - أخذ لقطة (Commit) للحاوية محلياً"
	@echo ""
	@echo -e "$(GREEN)المحرك الجغرافي [geo_engine]:$(NC)"
	@echo "  make mm         - تسجيل تغييرات الموديل (Makemigrations)"
	@echo "  make migrate    - حقن البيانات في PostGIS (Migrate)"
	@echo "  make sh         - الدخول لسطر أوامر الحاوية (Bash)"
	@echo "  make shell      - الدخول لبيئة بايثون (Django Shell)"
	@echo ""
	@echo -e "$(GREEN)المهام والذكاء (Temporal/AI):$(NC)"
	@echo "  make worker      - تشغيل محرك المهام الخلفية والزمانية"
	@echo ""
	@echo -e "$(GREEN)الصيانة والرقابة (الـ 2GB):$(NC)"
	@echo "  make size       - تقرير استهلاك المساحة والموارد"
	@echo "  make clean      - تنظيف الكاش واليتم (Prune) لاستعادة المساحة"
	@echo "  make destroy    - الحذف النووي (تصفير المساحة بالكامل)"
	@echo -e "--------------------------------------------------"

# --- أوامر البناء والتشغيل ---

build: clean
	@echo -e "$(CYAN)⚙️ بدء بناء AGRO_TECH...$(NC)"
	docker-compose up -d --build
	@$(MAKE) size

up:
	@docker-compose up -d

stop:
	@docker-compose stop

restart:
	@docker-compose restart

down:
	@docker-compose down

sh:
	@docker-compose exec web bash

logs:
	@docker-compose logs -f web

ps:
	@docker-compose ps

# --- أوامر المحرك الجغرافي والبيانات ---

mm:
	@echo -e "$(CYAN)📝 تسجيل التغييرات في [geo_engine]...$(NC)"
	docker-compose exec web python manage.py makemigrations geo_engine

migrate:
	@echo -e "$(CYAN)🌍 حقن البيانات في PostGIS...$(NC)"
	docker-compose exec web python manage.py migrate geo_engine

shell:
	docker-compose exec web python manage.py shell

worker:
	@echo -e "$(YELLOW)⏳ تشغيل محرك المهام الزمانية (Temporal/QCluster)...$(NC)"
	docker-compose exec web python manage.py qcluster

# --- أوامر حفظ الصورة والسيادة الرقمية (الرفع المباشر) ---

save:
	@echo -e "$(CYAN)💾 حفظ حالة الحاوية [$(CONTAINER_NAME)] كصورة جديدة...$(NC)"
	$(eval NEW_TAG := backup_$(shell date +%Y%m%d_%H%M%S))
	@docker commit $(CONTAINER_NAME) $(IMAGE_URL):$(NEW_TAG)
	@docker tag $(IMAGE_URL):$(NEW_TAG) $(IMAGE_URL):latest
	@echo -e "$(GREEN)✅ تم حفظ الصورة محلياً باسم: latest$(NC)"

publish: save
	@echo -e "$(YELLOW)🚀 جاري الرفع إلى GitHub Container Registry...$(NC)"
	@docker push $(IMAGE_URL):latest
	@echo -e "$(GREEN)✨ تم الرفع بنجاح! مشروعك الآن آمن سحابياً على GitHub.$(NC)"

# --- أوامر الصيانة والمساحة ---

size:
	@echo -e "$(CYAN)📊 تقرير المساحة الحالي (الحد 2GB):$(NC)"
	@echo "-------------------------------------------"
	@docker system df | grep -E "Images|Containers|Local Volumes"
	@echo "-------------------------------------------"

list_imgs:
	@docker images --format "table {{.Repository}}\t{{.Tag}}\t{{.ID}}\t{{.Size}}"

remove_img:
	@if [ -z "$(IMG_ID)" ]; then echo -e "$(RED)خطأ: يجب تحديد معرف الصورة. مثال: make remove_img IMG_ID=a1b2$(NC)"; exit 1; fi
	@docker rmi $(IMG_ID)

clean:
	@echo -e "$(YELLOW)🧹 تنظيف ملفات الكاش ومخلفات Docker...$(NC)"
	find . -type d -name "__pycache__" -exec rm -rf {} +
	find . -type f -name "*.py[co]" -delete
	docker image prune -f
	docker builder prune -f

destroy:
	@echo -e "$(RED)⚠️ حذف شامل للنظام والبيانات...$(NC)"
	docker-compose down --volumes --rmi all
	@$(MAKE) clean