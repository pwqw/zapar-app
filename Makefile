.PHONY: help build docker-build dev dev-live dev-static docker-run docker-shell web-build web-build-docker analyze-docker web-serve web-serve-docker test integration-screenshots-ci integration-screenshots stop clean clean-docker logs shell reload restart cache-list cache-prune cache-prune-all

-include .env

FLUTTER_VERSION := 3.27.4
LOCK_HASH := $(shell shasum -a 256 pubspec.lock | awk '{print substr($$1,1,12)}')
VOLUME_SUFFIX := $(FLUTTER_VERSION)-$(LOCK_HASH)

IMAGE_NAME ?= koel-dev
CONTAINER_NAME_DEV ?= koel-dev
CONTAINER_NAME_TEST ?= koel-dev-test
DOCKER_VOLUME_PREFIX ?= koel

PUB_CACHE_VOLUME := $(DOCKER_VOLUME_PREFIX)-pub-$(VOLUME_SUFFIX)
DART_TOOL_VOLUME := $(DOCKER_VOLUME_PREFIX)-darttool-$(VOLUME_SUFFIX)
BUILD_VOLUME := $(DOCKER_VOLUME_PREFIX)-build-$(VOLUME_SUFFIX)

help:
	@echo "Comandos:"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "  %-18s %s\n", $$1, $$2}'
	@echo ""
	@echo "Cache actual: $(VOLUME_SUFFIX)"

build: ## Construir imagen Docker (Flutter + web)
	DOCKER_BUILDKIT=1 docker build -t $(IMAGE_NAME) .

docker-build: build ## Alias

dev: dev-live ## Servidor HTTP en Docker (hot reload). http://localhost:8080

dev-live: ## flutter run web-server en contenedor (puerto 8080, hot reload con r/R)
	@docker stop $(CONTAINER_NAME_DEV) 2>/dev/null || true
	docker run --rm -it \
		--name $(CONTAINER_NAME_DEV) \
		-p 8080:8080 \
		-v $(PWD):/app \
		-v $(DART_TOOL_VOLUME):/app/.dart_tool \
		-v $(BUILD_VOLUME):/app/build \
		-v $(PUB_CACHE_VOLUME):/var/pub-cache \
		$(IMAGE_NAME) \
		sh -lc "flutter pub get && flutter run -d web-server --web-hostname 0.0.0.0 --web-port 8080"

reload: ## Hot reload desde otra terminal (señal SIGUSR1 al proceso flutter)
	@PID=$$(docker exec $(CONTAINER_NAME_DEV) pgrep -f "flutter run" 2>/dev/null) && \
		docker exec $(CONTAINER_NAME_DEV) kill -USR1 $$PID && \
		echo "Hot reload enviado (PID $$PID)" || \
		echo "No encontré el proceso flutter. ¿Está corriendo make dev?"

restart: ## Hot restart desde otra terminal (señal SIGUSR2 al proceso flutter)
	@PID=$$(docker exec $(CONTAINER_NAME_DEV) pgrep -f "flutter run" 2>/dev/null) && \
		docker exec $(CONTAINER_NAME_DEV) kill -USR2 $$PID && \
		echo "Hot restart enviado (PID $$PID)" || \
		echo "No encontré el proceso flutter. ¿Está corriendo make dev?"

dev-static: ## build web + python http.server (sin hot reload)
	@docker stop $(CONTAINER_NAME_DEV) 2>/dev/null || true
	docker run --rm \
		--name $(CONTAINER_NAME_DEV) \
		-p 8080:8080 \
		-v $(PWD):/app \
		-v $(DART_TOOL_VOLUME):/app/.dart_tool \
		-v $(BUILD_VOLUME):/app/build \
		-v $(PUB_CACHE_VOLUME):/var/pub-cache \
		$(IMAGE_NAME) \
		sh -lc "flutter pub get && flutter build web --release && python3 -m http.server 8080 --directory build/web"

docker-run:
	docker run --rm -it $(IMAGE_NAME)

docker-shell:
	docker run --rm -it \
		-v $(PWD):/app \
		-v $(DART_TOOL_VOLUME):/app/.dart_tool \
		-v $(BUILD_VOLUME):/app/build \
		-v $(PUB_CACHE_VOLUME):/var/pub-cache \
		$(IMAGE_NAME) /bin/bash

web-build:
	flutter build web --release

web-build-docker:
	docker run --rm \
		-v $(PWD):/app \
		-v $(DART_TOOL_VOLUME):/app/.dart_tool \
		-v $(BUILD_VOLUME):/app/build \
		-v $(PUB_CACHE_VOLUME):/var/pub-cache \
		$(IMAGE_NAME) \
		sh -lc "flutter pub get && flutter build web --release"

analyze: ## flutter analyze en imagen koel-dev (warnings/info no fallan el exit code)
	docker run --rm \
		-v $(PWD):/app \
		-v $(DART_TOOL_VOLUME):/app/.dart_tool \
		-v $(BUILD_VOLUME):/app/build \
		-v $(PUB_CACHE_VOLUME):/var/pub-cache \
		$(IMAGE_NAME) \
		sh -lc "flutter pub get && flutter analyze --no-fatal-warnings --no-fatal-infos"

web-serve:
	flutter run -d web-server --web-hostname localhost --web-port=8080

web-serve-docker:
	docker run --rm -p 8080:8080 \
		-v $(PWD):/app \
		-v $(DART_TOOL_VOLUME):/app/.dart_tool \
		-v $(BUILD_VOLUME):/app/build \
		-v $(PUB_CACHE_VOLUME):/var/pub-cache \
		$(IMAGE_NAME) \
		sh -lc "flutter pub get && flutter run -d web-server --web-hostname 0.0.0.0 --web-port 8080"

test: ## Tests en Docker (build_runner + flutter test)
	@docker stop $(CONTAINER_NAME_TEST) 2>/dev/null || true
	@docker rm $(CONTAINER_NAME_TEST) 2>/dev/null || true
	docker run --rm \
		--name $(CONTAINER_NAME_TEST) \
		-v $(PWD):/app \
		-v $(DART_TOOL_VOLUME):/app/.dart_tool \
		-v $(BUILD_VOLUME):/app/build \
		-v $(PUB_CACHE_VOLUME):/var/pub-cache \
		$(IMAGE_NAME) \
		sh -c "flutter pub get && flutter pub run build_runner build --delete-conflicting-outputs && flutter test"

# integration_test Android necesita SDK/emulador; la imagen koel-dev solo precachea web.
# Usar este target en CI (flutter-action) o en un host con `flutter` + Android toolchain.
# FORM_FACTOR=phone|tablet (prefijo de nombres de captura).
integration-screenshots-ci: ## flutter test integration_test/screenshot_journey_test.dart (host con Android)
	flutter pub get
	flutter test integration_test/screenshot_journey_test.dart \
		--dart-define-from-file=screenshot_defines.json

# Misma convención Docker que `test`; fallará en la imagen actual sin Android SDK — usar integration-screenshots-ci o CI.
integration-screenshots: ## integration_test screenshots en Docker (requiere imagen con Android o fallo al compilar APK)
	@docker stop $(CONTAINER_NAME_TEST) 2>/dev/null || true
	@docker rm $(CONTAINER_NAME_TEST) 2>/dev/null || true
	docker run --rm \
		--name $(CONTAINER_NAME_TEST) \
		--network host \
		-v $(PWD):/app \
		-v $(DART_TOOL_VOLUME):/app/.dart_tool \
		-v $(BUILD_VOLUME):/app/build \
		-v $(PUB_CACHE_VOLUME):/var/pub-cache \
		-e FORM_FACTOR=$(or $(FORM_FACTOR),phone) \
		-e SCREENSHOT_WITH_BACKEND=$(or $(SCREENSHOT_WITH_BACKEND),false) \
		-e KOEL_HOST=$(KOEL_HOST) \
		-e KOEL_EMAIL=$(KOEL_EMAIL) \
		-e KOEL_PASSWORD=$(KOEL_PASSWORD) \
		-e SCREENSHOT_SEARCH_TERM=$(or $(SCREENSHOT_SEARCH_TERM),zamba) \
		$(IMAGE_NAME) \
		sh -c 'flutter pub get && flutter test integration_test/screenshot_journey_test.dart \
			--dart-define=INTEGRATION_TEST=true \
			--dart-define=SCREENSHOT_MODE=true \
			--dart-define=FORM_FACTOR=$${FORM_FACTOR} \
			--dart-define=SCREENSHOT_WITH_BACKEND=$${SCREENSHOT_WITH_BACKEND} \
			--dart-define=KOEL_HOST=$${KOEL_HOST} \
			--dart-define=KOEL_EMAIL=$${KOEL_EMAIL} \
			--dart-define=KOEL_PASSWORD=$${KOEL_PASSWORD} \
			--dart-define=SCREENSHOT_SEARCH_TERM=$${SCREENSHOT_SEARCH_TERM}'

stop:
	@docker stop $(CONTAINER_NAME_DEV) $(CONTAINER_NAME_TEST) 2>/dev/null || true
	@docker rm $(CONTAINER_NAME_DEV) $(CONTAINER_NAME_TEST) 2>/dev/null || true

clean:
	flutter clean
	rm -rf build/

clean-docker: stop
	@docker rmi $(IMAGE_NAME) 2>/dev/null || true
	@docker volume rm $(PUB_CACHE_VOLUME) $(DART_TOOL_VOLUME) $(BUILD_VOLUME) 2>/dev/null || true

logs:
	docker logs -f $(CONTAINER_NAME_DEV)

shell: docker-shell

cache-list: ## Listar caches Docker de este prefijo (DOCKER_VOLUME_PREFIX)
	@docker volume ls --format '{{.Name}}' | awk '/^$(DOCKER_VOLUME_PREFIX)-(pub|darttool|build)-/ {print}'

cache-prune: ## Borrar caches viejos y conservar el hash actual
	@docker volume ls --format '{{.Name}}' | awk '/^$(DOCKER_VOLUME_PREFIX)-(pub|darttool|build)-/ && $$0 !~ /$(VOLUME_SUFFIX)$$/ {print}' | xargs -r docker volume rm

cache-prune-all: ## Borrar todos los caches Docker de este prefijo
	@docker volume ls --format '{{.Name}}' | awk '/^$(DOCKER_VOLUME_PREFIX)-(pub|darttool|build)-/ {print}' | xargs -r docker volume rm
