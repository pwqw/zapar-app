# Patches — Zapar fork de koel/player

## Filosofía

Este repositorio es un fork de [koel/player](https://github.com/koel/player). La rama `master` sigue a `upstream/master` con parches propios aplicados **en orden secuencial y reproducible**.

Cada parche es un archivo `.patch` (generado con `git format-patch`) acompañado de un `.md` que documenta su propósito y contiene instrucciones para un agente de programación.

## Índice de parches

| # | Archivo | Descripción | Dependencias |
|---|---------|-------------|--------------|
| 001 | `001-docker-dev.patch` | Dockerfile y .dockerignore para desarrollo local | ninguna |
| 002 | `002-ci-workflow.patch` | GitHub Actions: CI + build + deploy a Play Store | ninguna |
| 003 | `003-android-signing.patch` | Gradle: applicationId configurable, minSdk, firma release | ninguna |
| 004 | `004-android-signing-docs.patch` | Documentación de Play Store signing | 003 |
| 005 | `005-web-dev-stub.patch` | Makefile + audio stub + guards kIsWeb para dev en navegador | ninguna |

## Flujo de aplicación

```bash
# 1. Partir de upstream limpio
git fetch upstream
git checkout -b vendor/master upstream/master

# 2. Aplicar cadena
git am patches/*.patch

# 3. Si falla un parche:
#    - Leer el .md del parche que falló
#    - Resolver conflicto según instrucciones
#    - git am --continue

# 4. Verificar
flutter analyze   # o flutter build apk --debug
```

## Regenerar un parche

```bash
# Desde la rama con el cambio aplicado:
git format-patch -1 HEAD -o patches/
# Renombrar al número correcto
mv patches/0001-*.patch patches/NNN-nombre.patch
```
