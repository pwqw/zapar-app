# 003 — Android applicationId (Zapar)

## Propósito
Distinguir el paquete Android de Zapar del upstream Koel (`phanan.koel.app`). La firma con `key.properties` y `signingConfigs` **ya está** en `upstream/master`; este parche solo cambia `applicationId` a `com.zapar.app`.

## Archivos afectados
- `android/app/build.gradle` — `defaultConfig.applicationId`

## Orden de actualización
- Tras rebases grandes de upstream, si cambian líneas alrededor de `defaultConfig`, volver a generar el parche con `git diff upstream/master -- android/app/build.gradle`.

## Dependencias
Ninguna (coherente con **002** que usa `PACKAGE_NAME` en secrets).

## Criterio de éxito
- `git apply --check` limpio sobre `upstream/master` tras **001** (001 no toca Android).
- `flutter build appbundle` con keystore configurado sigue alineado con la documentación del parche **004**.
