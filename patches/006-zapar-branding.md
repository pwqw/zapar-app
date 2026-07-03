# 006 — Zapar (branding)

## Propósito

Consolidar la cadena de commits **«patchear: brand …»** de la rama `dev-web` (en este clon no existe `dev-deb`; los cinco commits están solo en `dev-web`):

- `aa4b54f` — patchear: brand 1  
- `d17b5d9` — patchear: brand 2, android y .env fallback  
- `73a1816` — patchear: brand 2.1, QR login button colores  
- `10fb449` — patchear: brand 3, custom host  
- `8863eb3` — patchear: brand 2.2, QR button bulletproof + ColorScheme primary  

Generado con:

`git diff aa4b54f^..8863eb3 -- . ':(exclude).github'`

(excluye cambios de workflows en `.github` que no forman parte del branding).

## Archivos modificados (resumen)

- **Android**: `ar.zap.app`, etiqueta «Zapar», iconos `mipmap-*`, `MainActivity` (`package ar.zap.app`), `namespace` en `android/build.gradle`.
- **Tema**: paleta verde (`AppColors`, cabeceras, mini player, listas, pull-to-refresh, gradiente de fondo en lugar de imagen en `gradient_decorated_container`).
- **Login**: host fijo `https://zap.ar`, sin campo de URL; QR solo pasa `token` (alineado con backend Zapar).
- **Web PWA**: `web/index.html` y `web/manifest.json` (nombre Zapar, colores).
- **Assets**: logos e imágenes por defecto.
- **`.env.example`**: `ANDROID_APPLICATION_ID=ar.zap.app`.
- **`.flutter`**: el commit *brand 1* elimina el submódulo `.flutter`; si tu flujo Docker/Makefile depende de él, restaura el submódulo o ignora este hunk al aplicar.

## Actualización

- Tras **003**: el fallback de `applicationId` en `build.gradle` pasa de `phanan.koel.app` a `ar.zap.app` (coherente con este parche).
- Tras **005**: `web/index.html` / manifest ya pueden estar tocados; resolver solapes con upstream revisando meta `title`/manifest en conjunto.
- Si upstream cambia `qr_login_button`, `login.dart` o el contrato del QR (host + token), revisar los hunks de login/QR.

## Criterio de éxito

- [ ] `git apply --check patches/006-zapar-branding.patch` sobre `upstream/master` con **001–005** ya aplicados.
- [ ] `flutter analyze` y `flutter build web` (o `apk`) sin errores nuevos.
