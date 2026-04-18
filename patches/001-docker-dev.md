# 001 — Docker dev (Flutter web)

## Contenido

- `Dockerfile` — toolchain Flutter para desarrollo web (volumen de código en runtime).
- `.dockerignore` — contexto de build reducido.
- `Makefile` — `make build`, `make dev`, tests en contenedor, caches por hash de `pubspec.lock`.

## Uso rápido

- `make build` — Construye la imagen `koel-dev` (o el nombre en `.env`: `IMAGE_NAME`).
- `make dev` — Servidor con hot reload en `http://localhost:8080`.

```bash
docker build -t koel-dev .
```

Personalización: copia `.env.example` a `.env` (gitignored).
