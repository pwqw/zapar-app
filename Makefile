.PHONY: docker-build docker-run docker-shell dev web-build web-serve clean web-dev

docker-build:
	docker build -t zapar-dev .

docker-run:
	docker run --rm zapar-dev

docker-shell:
	docker run --rm -it zapar-dev /bin/bash

dev: web-build-docker
	@echo "✅ Web build complete. Open http://localhost:8080/build/web/index.html"

web-build:
	flutter build web --release

web-build-docker:
	docker run --rm zapar-dev flutter build web --release

web-serve:
	flutter run -d web --web-port=8080

web-serve-docker:
	docker run --rm -p 8080:8080 zapar-dev flutter run -d web --web-port=8080

clean:
	flutter clean
	rm -rf build/ web/
