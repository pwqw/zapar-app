# syntax=docker/dockerfile:1

# Build Flutter app in container
FROM debian:bookworm

# Install system dependencies
RUN apt-get update && apt-get install -y \
    git \
    curl \
    unzip \
    xz-utils \
    build-essential \
    libglu1-mesa \
    libstdc++-12-dev \
    && rm -rf /var/lib/apt/lists/*

# Install Flutter SDK
WORKDIR /opt
RUN git clone https://github.com/flutter/flutter.git -b stable --depth 1
ENV PATH="/opt/flutter/bin:/opt/flutter/bin/cache/dart-sdk/bin:$PATH"

# Pre-download platform tooling
RUN flutter precache

# Create app directory
WORKDIR /app

# Copy pubspec files (cache dependencies)
COPY pubspec.yaml pubspec.lock ./

# Get dependencies
RUN flutter pub get

# Copy entire app
COPY . .

# Build & run
EXPOSE 8080
CMD ["flutter", "run", "-d", "chrome", "--web-port=8080"]
