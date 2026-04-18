.PHONY: help build dev reload restart shell analyze test stop clean logs volumes-list volumes-prune-old volumes-prune-all

-include .env

FLUTTER_VERSION := 3.29.3
LOCK_HASH := $(shell shasum -a 256 pubspec.lock | awk '{print substr($$1,1,12)}')
VOLUME_SUFFIX := $(FLUTTER_VERSION)-$(LOCK_HASH)

IMAGE_NAME ?= koel-dev
CONTAINER_NAME_DEV ?= koel-dev
CONTAINER_NAME_TEST ?= koel-dev-test
DOCKER_VOLUME_PREFIX ?= koel

PUB_CACHE_VOLUME := $(DOCKER_VOLUME_PREFIX)-pub-$(VOLUME_SUFFIX)
DART_TOOL_VOLUME := $(DOCKER_VOLUME_PREFIX)-darttool-$(VOLUME_SUFFIX)
BUILD_VOLUME := $(DOCKER_VOLUME_PREFIX)-build-$(VOLUME_SUFFIX)

# Montajes estándar: código + caches Flutter (evita duplicar en cada target)
DOCKER_APP_VOLUMES := -v $(PWD):/app \
	-v $(DART_TOOL_VOLUME):/app/.dart_tool \
	-v $(BUILD_VOLUME):/app/build \
	-v $(PUB_CACHE_VOLUME):/var/pub-cache

help:
	@echo "Comandos (solo Docker; requiere imagen $(IMAGE_NAME)):"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "  %-18s %s\n", $$1, $$2}'
	@echo ""
	@echo "Cache actual: $(VOLUME_SUFFIX)"

build: ## Construir imagen Docker (Flutter + web)
	DOCKER_BUILDKIT=1 docker build -t $(IMAGE_NAME) .

KOEL_HOST_DEV ?= http://localhost:8000

dev: ## Servidor HTTP en Docker (hot reload). http://localhost:8080
	@docker stop $(CONTAINER_NAME_DEV) 2>/dev/null || true
	docker run --rm -it \
		--name $(CONTAINER_NAME_DEV) \
		-p 8080:8080 \
		$(DOCKER_APP_VOLUMES) \
		$(IMAGE_NAME) \
		sh -lc "flutter pub get && flutter run -d web-server --web-hostname 0.0.0.0 --web-port 8080 --dart-define=KOEL_HOST=$(or $(KOEL_HOST),$(KOEL_HOST_DEV))"

reload: ## Hot reload desde otra terminal (SIGUSR1 al proceso flutter)
	@PID=$$(docker exec $(CONTAINER_NAME_DEV) pgrep -f "flutter run" 2>/dev/null) && \
		docker exec $(CONTAINER_NAME_DEV) kill -USR1 $$PID && \
		echo "Hot reload enviado (PID $$PID)" || \
		echo "No encontré el proceso flutter. ¿Está corriendo make dev?"

restart: ## Hot restart desde otra terminal (SIGUSR2 al proceso flutter)
	@PID=$$(docker exec $(CONTAINER_NAME_DEV) pgrep -f "flutter run" 2>/dev/null) && \
		docker exec $(CONTAINER_NAME_DEV) kill -USR2 $$PID && \
		echo "Hot restart enviado (PID $$PID)" || \
		echo "No encontré el proceso flutter. ¿Está corriendo make dev?"

shell: ## Bash con volúmenes del proyecto
	docker run --rm -it $(DOCKER_APP_VOLUMES) $(IMAGE_NAME) /bin/bash

analyze: ## flutter analyze (warnings/info no fallan el exit code)
	docker run --rm $(DOCKER_APP_VOLUMES) $(IMAGE_NAME) \
		sh -lc "flutter pub get && flutter analyze --no-fatal-warnings --no-fatal-infos"

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

stop:
	@docker stop $(CONTAINER_NAME_DEV) $(CONTAINER_NAME_TEST) 2>/dev/null || true
	@docker rm $(CONTAINER_NAME_DEV) $(CONTAINER_NAME_TEST) 2>/dev/null || true

clean: ## flutter clean + borrar build/ dentro del árbol (vía contenedor)
	docker run --rm $(DOCKER_APP_VOLUMES) $(IMAGE_NAME) \
		sh -lc "flutter clean && rm -rf build/"

logs:
	docker logs -f $(CONTAINER_NAME_DEV)

volumes-list: ## Listar volúmenes Docker de este prefijo
	@docker volume ls --format '{{.Name}}' | awk '/^$(DOCKER_VOLUME_PREFIX)-(pub|darttool|build)-/ {print}'

volumes-prune-old: ## Borrar volúmenes de caches antiguos (conserva el hash actual)
	@for vol in $$(docker volume ls --format '{{.Name}}' | awk '/^$(DOCKER_VOLUME_PREFIX)-(pub|darttool|build)-/ && $$0 !~ /$(VOLUME_SUFFIX)$$/ {print}'); do \
		docker volume rm "$$vol" 2>/dev/null || true; \
	done

volumes-prune-all: ## Borrar todos los volúmenes de cache de este prefijo
	@for vol in $$(docker volume ls --format '{{.Name}}' | awk '/^$(DOCKER_VOLUME_PREFIX)-(pub|darttool|build)-/ {print}'); do \
		docker volume rm "$$vol" 2>/dev/null || true; \
	done
