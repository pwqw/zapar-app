# syntax=docker/dockerfile:1
# Dockerfile para desarrollo Flutter (BuildKit para cache mounts)

FROM ubuntu:22.04

# Instalar dependencias mínimas
RUN apt-get update && apt-get install -y \
    curl \
    git \
    unzip \
    xz-utils \
    && rm -rf /var/lib/apt/lists/*

# Instalar Flutter (Dart 3.x, requerido por ulid ^2.0.1 y alineado con CI/producción)
ENV FLUTTER_VERSION=3.16.9
ENV FLUTTER_HOME=/opt/flutter
ENV PATH="$FLUTTER_HOME/bin:$PATH"
# Pub cache en ruta fija para montar volumen y persistir entre runs (doc: dart.dev/tools/pub/environment-variables)
ENV PUB_CACHE=/var/pub-cache

# Descargar Flutter desde tarball oficial (evita git clone y fallos TLS/GnuTLS en el contenedor)
RUN --mount=type=cache,target=/downloads \
    ( [ -f /downloads/flutter-${FLUTTER_VERSION}.tar.xz ] || \
        curl -fSL --retry 5 --retry-delay 10 --retry-all-errors \
        "https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_${FLUTTER_VERSION}-stable.tar.xz" \
        -o /downloads/flutter-${FLUTTER_VERSION}.tar.xz ) && \
    tar -xJf /downloads/flutter-${FLUTTER_VERSION}.tar.xz -C /opt

# Evitar "dubious ownership" y que Flutter reporte 0.0.0-unknown (usa git para la versión)
RUN git config --global --add safe.directory /opt/flutter

# Cache mount de BuildKit: persiste descargas de precache entre builds (doc: docs.docker.com/build/guide/mounts)
# Flutter guarda Dart SDK y artefactos web en FLUTTER_HOME/bin/cache; lo enlazamos al mount y luego copiamos a la imagen
RUN --mount=type=cache,target=/flutter-precache \
    rm -rf ${FLUTTER_HOME}/bin/cache && \
    ln -s /flutter-precache ${FLUTTER_HOME}/bin/cache && \
    flutter config --no-analytics --enable-web && \
    flutter precache --web && \
    rm ${FLUTTER_HOME}/bin/cache && \
    cp -a /flutter-precache/. ${FLUTTER_HOME}/bin/cache/ && \
    flutter --version

RUN mkdir -p /var/pub-cache
WORKDIR /app

EXPOSE 7000

# El comando se define en docker-compose o make
CMD ["flutter", "run", "-d", "web-server", "--web-hostname", "0.0.0.0", "--web-port", "7000"]
