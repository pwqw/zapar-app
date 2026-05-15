# 003 — Android Signing & Gradle Config

## Propósito
Configurar el build de Android para que soporte firma con keystore externo (vía `key.properties`), `applicationId` configurable, y `minSdk 21` para máxima compatibilidad.

## Archivos afectados
- `android/app/build.gradle` — Configuración de signing, applicationId, minSdk

## Orden de construcción (desde upstream/master limpio)

1. Modificar `android/app/build.gradle`:

   a. **Agregar lectura de `key.properties`** al inicio del bloque android:
      ```groovy
      def keystoreProperties = new Properties()
      def keystorePropertiesFile = rootProject.file('key.properties')
      if (keystorePropertiesFile.exists()) {
          keystoreProperties.load(new FileInputStream(keystorePropertiesFile))
      }
      ```

   b. **Agregar bloque `signingConfigs`**:
      ```groovy
      signingConfigs {
          release {
              keyAlias keystoreProperties['keyAlias']
              keyPassword keystoreProperties['keyPassword']
              storeFile keystoreProperties['storeFile'] ? file(keystoreProperties['storeFile']) : null
              storePassword keystoreProperties['storePassword']
          }
      }
      ```

   c. **En `buildTypes.release`**: usar `signingConfig signingConfigs.release` en vez de debug

   d. **`applicationId`**: si upstream lo hardcodea, parametrizarlo o cambiar a `com.zapar.app` (o el paquete correspondiente según `PACKAGE_NAME`)

   e. **`minSdk`**: setear a `21` (Android 5.0) para máxima compatibilidad

2. **NO** crear `key.properties` en el repo (contiene secrets). Agregar a `.gitignore` si no está.

## Orden de actualización
- Si upstream modifica `build.gradle` (nueva compileSdk, targetSdk, plugins): re-aplicar los bloques de signing y minSdk sobre la nueva base
- Verificar que el namespace/applicationId no colisione con cambios upstream

## Dependencias
Ninguna.

## Criterio de éxito
- `flutter build appbundle --release` con `key.properties` presente genera un AAB firmado
- Sin `key.properties`, el build de debug sigue funcionando normalmente
- `minSdk` es 21 en el APK/AAB resultante
