.PHONY: docker-build docker-run docker-shell dev web-build web-serve clean

docker-build:
	docker build -t zapar-dev .

docker-run:
	docker run -it --rm zapar-dev

docker-shell:
	docker run -it --rm -v $(PWD):/app zapar-dev /bin/bash

dev:
	docker run -it --rm -p 8080:8080 -v $(PWD):/app zapar-dev flutter run -d chrome --web-port=8080

web-build:
	flutter build web --release

web-serve:
	flutter run -d chrome --web-port=8080

clean:
	flutter clean
	rm -rf build/ web/
