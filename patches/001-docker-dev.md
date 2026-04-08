# 001 — Docker Dev Environment

## Propósito
Imagen Docker solo con **toolchain Flutter** (Ubuntu 22.04, Flutter 3.27.4, web precache, Python para `http.server`). El código se monta con **volumen** en `make dev`; no se copia el repo en la imagen. Los caches de runtime quedan versionados por `Flutter + hash(pubspec.lock)` para evitar descargas y recompilaciones repetidas.

## Archivos afectados
- `Dockerfile` — Flutter fijado por tag, `PUB_CACHE=/var/pub-cache`, cache de `apt` con BuildKit, `CMD` por defecto `web-server` en `0.0.0.0:8080`
- `.dockerignore` — Reduce contexto de `docker build`
- `.gitignore` — Ignora artefactos generados por Flutter desktop/web durante el flujo Docker (`linux/flutter/ephemeral`, `macos/Flutter/ephemeral`, `GeneratedPluginRegistrant.swift`)
- `Makefile` — `build`, `dev` (= `dev-live`), `dev-static`, tests en contenedor, volúmenes versionados y comandos para listar/purgar cache

## Uso
- `make build` — Construye la imagen `zapar-dev`
- `make dev` — `docker run` con montaje de `$(PWD)` y caches `pub/.dart_tool/build`; servidor HTTP en **http://localhost:8080**
- `make dev-static` — `flutter build web --release` + `python3 -m http.server` sobre `build/web`
- `make cache-list` — Lista caches Docker del proyecto
- `make cache-prune` — Borra caches viejos y conserva el hash actual
- `make cache-prune-all` — Borra todos los caches Docker del proyecto

## Orden de actualización
Si upstream exige otra versión de Flutter/Dart, ajustar `FLUTTER_VERSION` y validar `flutter build web`.

## Criterio de éxito
- `docker build -t zapar-dev .` completa
- `make dev` expone la app en el puerto 8080
