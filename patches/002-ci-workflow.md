# 002 — CI/CD Workflow (GitHub Actions)

## Propósito
Pipeline de CI que compila el AAB de Android firmado y lo publica a Google Play Store (beta track). Incluye workflow de CI básico para PRs y uno de build+deploy para tags/releases.

## Archivos afectados
- `.github/workflows/build-deploy.yml` — Pipeline principal: build AAB firmado + upload a Play Store
- `.github/workflows/ci.yml` — CI básico para PRs (analyze + test)

## Orden de construcción (desde upstream/master limpio)

1. Crear `.github/workflows/ci.yml`:
   - Trigger: push a master, PRs
   - Steps: checkout, setup Flutter, `flutter analyze`, `flutter test`
   - Matrix opcional para múltiples versiones de Flutter

2. Crear `.github/workflows/build-deploy.yml`:
   - Trigger: push de tags `v*` o workflow_dispatch
   - Environment: `PlayStore` (para acceder a secrets)
   - Steps:
     a. Checkout
     b. Setup Java 17, Flutter
     c. Generar `key.properties` desde secrets (`KEYSTORE_BASE64`, `KEYSTORE_PASSWORD`, `KEY_ALIAS`, `KEY_PASSWORD`)
     d. Decodificar keystore de base64 a archivo
     e. `flutter build appbundle --release`
     f. Upload AAB como artefacto
     g. Publicar a Play Store usando `r0adkll/upload-google-play` o similar
        - `serviceAccountJsonPlainText: ${{ secrets.GOOGLE_PLAY_SERVICE_ACCOUNT }}`
        - `packageName: ${{ secrets.PACKAGE_NAME }}`
        - track: beta
     h. Crear GitHub Release con el AAB adjunto

3. Secrets requeridos (documentar en el .md, NO incluir valores):
   - `KEYSTORE_BASE64`, `KEYSTORE_PASSWORD`, `KEY_ALIAS`, `KEY_PASSWORD`
   - `PACKAGE_NAME`, `GOOGLE_PLAY_SERVICE_ACCOUNT`

## Orden de actualización
- Mantener la versión de Flutter del workflow alineada con la usada en Docker/local; la rama actual requiere Dart >= 3.4, por lo que no debe volver a 3.16.x
- Si cambia el `build.gradle` de upstream: verificar que `key.properties` sigue siendo compatible
- Si Google Play cambia la API: actualizar la action de upload

## Dependencias
Funciona mejor si el parche 003 (android-signing) ya está aplicado, pero técnicamente puede aplicarse independientemente.

## Criterio de éxito
- Push de un tag `v*` dispara el workflow
- El AAB se genera firmado correctamente
- El AAB se sube a Play Store (track beta) sin errores
- CI en PRs pasa con `flutter analyze` y `flutter test`
