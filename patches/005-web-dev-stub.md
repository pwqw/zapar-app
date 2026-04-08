# 005 — Web Dev Stub (desarrollo en navegador)

## Propósito
Permitir correr la app Flutter en el navegador para desarrollo rápido. Incluye un stub de audio handler (las APIs nativas no aplican en web), guards `kIsWeb`, compatibilidad sin `dart:io`/`Platform` en web, y `web/index.html` con bootstrap actual. Los targets Docker/Makefile de app están en el parche **001**.

**NOTA**: Este es un parche de DESARROLLO, no de producto. La app web no es para usuarios finales.

## Archivos afectados
- `lib/audio_handler_stub.dart` — Stub + `typedef KoelAudioHandler = AudioHandlerStub` para el import condicional
- `lib/main.dart` — `import 'audio_handler.dart' if (dart.library.html) 'audio_handler_stub.dart'` y `AudioService.init(builder: () => KoelAudioHandler(), …)` (en web `KoelAudioHandler` es el typedef del stub)
- `lib/providers/download_provider.dart` — Guards `kIsWeb` para filesystem/descargas
- `lib/ui/screens/initial.dart` — Skip de connectivity check en web
- `lib/audio_handler.dart`, `lib/ui/theme_data.dart`, `lib/ui/screens/main.dart`, `lib/ui/screens/info_sheet/info_sheet.dart` — Sin `dart:io`/`Platform`; usar `lib/utils/platform_compat.dart` (`isIOSDevice`)
- `lib/constants/images.dart`, `lib/utils/default_art_uri_io.dart`, `lib/utils/default_art_uri_web.dart` — Arte por defecto sin `File` en web (import condicional)
- `lib/utils/api_request.dart` — Cabeceras HTTP sin `dart:io`
- `web/index.html` — `flutter_bootstrap.js`; alinear con **001** / repo `web/` (ver tabla abajo)
- **Repo hermano `web/` (Koel Laravel)**: `Makefile` en la raíz del proyecto `zapar/web` — **no** forma parte de este `.patch` (otro git), pero cualquier cambio en bootstrap, puertos o despliegue del player debe revisarse **en conjunto** con `web/index.html`

### Coordinación obligatoria: `app/web/index.html` ↔ `web/Makefile`

El player Flutter (`app`) y la API/UI Koel (`web`) se desarrollan en repositorios distintos. Este parche solo puede versionar archivos bajo `app/`. Aun así:

| Repo | Ruta | Qué revisar al cambiar el otro |
|------|------|--------------------------------|
| **app** | `web/index.html` | `<base href>`, script de bootstrap, meta PWA |
| **web** | `Makefile` | `make dev` (p. ej. `:8000`), volúmenes, cómo se sirve el build o el proxy hacia el player |

**Orden sugerido para un agente** (checklist):

1. [ ] Leer `patches/001-docker-dev.md` si el cambio toca Docker/Makefile en **app** (toolchain Flutter).
2. [ ] Si se edita `app/web/index.html`, abrir `../web/Makefile` (desde `app/`, el clon de Koel en `zapar/web`) y comprobar que comentarios/puertos/targets sigan siendo coherentes con cómo se prueba el stack (Laravel `:8000` + player Flutter, habitualmente `:8080` vía `app/Makefile`).
3. [ ] Si se edita `web/Makefile` por integración Docker/dev, revisar `app/web/index.html` por si el bootstrap o `base href` deben reflejar la misma historia de despliegue.
4. [ ] Regenerar `patches/005-web-dev-stub.patch` con `git diff upstream/master -- <archivos de esta sección>` (misma lista que al aplicar el parche).
5. [ ] Commits: un commit en **app** con parches + `web/index.html`; si hubo cambios en `web/Makefile`, commit separado en el repo **web** (o misma descripción enlazando ambos).

## Orden de construcción (desde upstream/master limpio)

1. **Crear `lib/audio_handler_stub.dart`**:
   - Implementar una clase que satisfaga la interfaz de `AudioHandler` usada en la app
   - Todos los métodos son no-op o retornan valores vacíos
   - Import: `package:audio_service/audio_service.dart`

2. **Modificar `lib/main.dart`**:
   - Import condicional hacia el stub en web (ver arriba).
   - `AudioService.init(builder: () => KoelAudioHandler(), …)` — no usar `AudioHandlerStub` directamente en el código: el analizador no-web no lo ve; el typedef en el stub unifica el nombre.
   - **IMPORTANTE**: NO remover providers upstream (radio, download sync, etc.).

3. **Modificar `lib/providers/download_provider.dart`**:
   - Agregar `import 'package:flutter/foundation.dart';` si no está
   - Envolver operaciones de filesystem en `if (!kIsWeb) { ... }`
   - NO cambiar la lógica de descarga para mobile/desktop

4. **Modificar `lib/ui/screens/initial.dart`**:
   - Si `kIsWeb`, saltar el chequeo de conectividad (no bloquear en web)
   - NO cambiar el flujo para mobile

5. **Makefile / Docker**: Ver parche **001** (`make dev`, `web-build-docker`, `analyze-docker`, puerto 8080).

6. **Directorio `web/`**: Plantilla Flutter web; mínimo `web/index.html` con `flutter_bootstrap.js` (sin bloque legacy `serviceWorkerVersion`).

## Orden de actualización
- Si upstream agrega nuevos providers o cambia la interfaz de AudioHandler: actualizar el stub y los imports condicionales
- Si upstream modifica `main.dart` significativamente: re-evaluar dónde colocar los guards
- **Regla de oro**: los cambios web NUNCA deben alterar el comportamiento en mobile/desktop

## Dependencias
Ninguna.

## Criterio de éxito
- `flutter run -d chrome` levanta la app sin crashes
- `flutter build web` completa sin errores
- `flutter run -d android` (o iOS) sigue funcionando exactamente como upstream
- `flutter test` pasa sin regresiones
