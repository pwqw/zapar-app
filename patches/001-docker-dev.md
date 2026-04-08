# 001 — Docker Dev Environment

## Propósito
Agregar soporte de Docker para desarrollo local del proyecto Flutter. Permite levantar un contenedor con el SDK de Flutter configurado, sin necesidad de instalar Flutter en el host.

## Archivos afectados
- `Dockerfile` — Imagen basada en Flutter SDK con dependencias del proyecto
- `.dockerignore` — Exclusiones para el build context

## Orden de construcción (desde upstream/master limpio)

1. Crear `Dockerfile` en la raíz del proyecto (`app/`):
   - Base: imagen oficial de Flutter o Ubuntu + Flutter SDK
   - Instalar dependencias del sistema necesarias para Flutter
   - Copiar `pubspec.yaml` y `pubspec.lock` primero (cache de deps)
   - Luego copiar el resto del código
   - Working dir: `/app`
   - CMD por defecto: `flutter run` o shell interactivo

2. Crear `.dockerignore`:
   - Excluir: `.dart_tool/`, `build/`, `.flutter-plugins`, `.idea/`, `*.iml`, `.git/`
   - Incluir: todo lo demás necesario para el build

3. Verificar: `docker build -t zapar-dev .` debe completar sin errores

## Orden de actualización
Si upstream agrega dependencias de sistema nuevas o cambia la estructura de directorios, actualizar el Dockerfile acorde. Revisar `pubspec.yaml` por nuevas dependencias nativas.

## Dependencias
Ninguna. Este parche es independiente.

## Criterio de éxito
- `docker build .` completa sin errores
- El contenedor puede ejecutar `flutter analyze` y `flutter test` correctamente
