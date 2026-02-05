.PHONY: help build dev test stop clean logs shell

# Variables
IMAGE_NAME := zapar-app
CONTAINER_NAME_DEV := zapar-dev
CONTAINER_NAME_TEST := zapar-test
PUB_CACHE_VOLUME := zapar-pub-cache

help: ## Mostrar ayuda
	@echo "Comandos disponibles:"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-15s\033[0m %s\n", $$1, $$2}'

build: ## Construir imagen (BuildKit para cache de Flutter/precache)
	DOCKER_BUILDKIT=1 docker build -t $(IMAGE_NAME) .

dev: ## Desarrollo con hot reload (puerto 7000)
	docker run -it --rm \
		--name $(CONTAINER_NAME_DEV) \
		-p 7000:7000 \
		-v $(PWD):/app \
		-v /app/.dart_tool \
		-v /app/build \
		-v $(PUB_CACHE_VOLUME):/var/pub-cache \
		$(IMAGE_NAME)

test: ## Ejecutar tests
	docker run --rm \
		--name $(CONTAINER_NAME_TEST) \
		-v $(PWD):/app \
		-v $(PUB_CACHE_VOLUME):/var/pub-cache \
		$(IMAGE_NAME) \
		flutter test

stop: ## Detener contenedores
	@docker stop $(CONTAINER_NAME_DEV) 2>/dev/null || true

clean: ## Limpiar todo (imagen, volúmenes y contenedores)
	@docker stop $(CONTAINER_NAME_DEV) 2>/dev/null || true
	@docker rm $(CONTAINER_NAME_DEV) $(CONTAINER_NAME_TEST) 2>/dev/null || true
	@docker rmi $(IMAGE_NAME) 2>/dev/null || true
	@docker volume rm $(PUB_CACHE_VOLUME) 2>/dev/null || true

logs: ## Ver logs del contenedor dev
	docker logs -f $(CONTAINER_NAME_DEV)

shell: ## Shell en contenedor
	docker run -it --rm \
		-v $(PWD):/app \
		-v $(PUB_CACHE_VOLUME):/var/pub-cache \
		$(IMAGE_NAME) \
		/bin/bash
