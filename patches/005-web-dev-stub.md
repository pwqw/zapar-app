# 005 — Web Dev Stub (desarrollo en navegador)

## Propósito
Permitir correr la app Flutter en el navegador para desarrollo rápido. Incluye un stub de audio handler (ya que las APIs de audio nativas no funcionan en web), guards `kIsWeb`, y targets de Makefile para build/serve web.

**NOTA**: Este es un parche de DESARROLLO, no de producto. La app web no es para usuarios finales.

## Archivos afectados
- `lib/audio_handler_stub.dart` — Stub que reemplaza el audio handler real en web
- `lib/main.dart` — Import condicional del stub cuando `kIsWeb`
- `lib/providers/download_provider.dart` — Guards `kIsWeb` para evitar operaciones de filesystem
- `lib/ui/screens/initial.dart` — Skip de connectivity check en web
- `Makefile` — Targets `web-build`, `web-serve` para desarrollo
- `web/` — Assets y configuración para Flutter web build

## Orden de construcción (desde upstream/master limpio)

1. **Crear `lib/audio_handler_stub.dart`**:
   - Implementar una clase que satisfaga la interfaz de `AudioHandler` usada en la app
   - Todos los métodos son no-op o retornan valores vacíos
   - Import: `package:audio_service/audio_service.dart`

2. **Modificar `lib/main.dart`**:
   - Agregar import condicional:
     ```dart
     import 'audio_handler.dart' if (dart.library.html) 'audio_handler_stub.dart';
     ```
   - En la inicialización, si `kIsWeb`, usar el stub en vez del handler real
   - **IMPORTANTE**: NO remover providers que existen en upstream (radio, download sync, etc.). Solo agregar el condicional web.

3. **Modificar `lib/providers/download_provider.dart`**:
   - Agregar `import 'package:flutter/foundation.dart';` si no está
   - Envolver operaciones de filesystem en `if (!kIsWeb) { ... }`
   - NO cambiar la lógica de descarga para mobile/desktop

4. **Modificar `lib/ui/screens/initial.dart`**:
   - Si `kIsWeb`, saltar el chequeo de conectividad (no bloquear en web)
   - NO cambiar el flujo para mobile

5. **Crear targets en `Makefile`**:
   ```makefile
   web-build:
   	flutter build web --release
   
   web-serve:
   	flutter run -d chrome --web-port=8080
   ```

6. **Directorio `web/`**: Si upstream no tiene `flutter create --platforms web .` generado, ejecutar ese comando y commitear los archivos base.

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
