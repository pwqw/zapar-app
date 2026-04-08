# syntax=docker/dockerfile:1.7
# Imagen de toolchain Flutter para desarrollo web (código vía volumen en runtime).

FROM ubuntu:22.04

ARG FLUTTER_VERSION=3.27.4

RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,target=/var/lib/apt,sharing=locked \
    apt-get update && apt-get install -y \
    curl \
    git \
    python3 \
    unzip \
    xz-utils \
    && rm -rf /var/lib/apt/lists/*

ENV FLUTTER_HOME=/opt/flutter
ENV PATH="$FLUTTER_HOME/bin:$PATH"
ENV PUB_CACHE=/var/pub-cache

RUN git clone --depth 1 --branch ${FLUTTER_VERSION} https://github.com/flutter/flutter.git ${FLUTTER_HOME}

RUN git config --global --add safe.directory /opt/flutter

RUN flutter config --no-analytics --enable-web && \
    flutter precache --web

RUN mkdir -p /var/pub-cache
WORKDIR /app

EXPOSE 8080

CMD ["flutter", "run", "-d", "web-server", "--web-hostname", "0.0.0.0", "--web-port", "8080", "--web-renderer", "html"]
