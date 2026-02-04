# CI/CD con GitHub Actions

Este documento describe la configuración de Integración Continua y Despliegue Continuo (CI/CD) para Zapar App usando GitHub Actions.

## 📋 Tabla de Contenidos

- [Resumen](#resumen)
- [Workflows Disponibles](#workflows-disponibles)
- [Configuración Inicial](#configuración-inicial)
- [Versionado](#versionado)
- [Uso](#uso)
- [Troubleshooting](#troubleshooting)

## Resumen

El proyecto utiliza dos workflows principales:

1. **Pull Request Validation** (`.github/workflows/flutter-pr.yml`)
   - Se ejecuta automáticamente en PRs
   - Valida código, ejecuta tests, genera APKs de debug
   - Feedback rápido para desarrollo

2. **Production Release Build** (`.github/workflows/flutter-release.yml`)
   - Se ejecuta manual o automáticamente con tags `v*`
   - Genera APKs y AAB firmados para producción
   - Crea releases de GitHub automáticamente

## Workflows Disponibles

### 1. Pull Request Validation

**Trigger:** Pull requests a `master`, `main`, o `develop`

**Jobs:**

#### Job 1: Analyze & Test (Bloqueante)
- ✅ Validación de `pubspec.yaml`
- ✅ `flutter analyze --no-fatal-infos`
- ✅ `dart format --set-exit-if-changed`
- ✅ `flutter test --coverage`
- 📊 Upload de coverage a Codecov

#### Job 2: Build Android Debug
- 📦 Genera 4 APKs de debug (split por ABI):
  - `app-armeabi-v7a-debug.apk` (ARM 32-bit)
  - `app-arm64-v8a-debug.apk` (ARM 64-bit)
  - `app-x86-debug.apk` (x86 32-bit, emuladores)
  - `app-x86_64-debug.apk` (x86 64-bit, emuladores)
- 💬 Comentario automático en PR con links de descarga
- ⏱️ Artifacts disponibles por **2 días**

**Características:**
- Tests BLOQUEANTES (deben pasar para merge)
- No requiere signing (debug builds)
- Cache de Flutter SDK, pub dependencies, y Gradle

### 2. Production Release Build

**Triggers:**
- 🔧 Manual: `Actions → Flutter Release Build → Run workflow`
- 🏷️ Automático: Push de tags `v*` (ej: `v2.2.6`)

**Environment:** `PlayStore` (requiere configuración de secrets)

**Fases:**

#### Fase 1: Validación Temprana
- 🔐 Verifica que todos los secrets estén configurados
- 🔑 Crea keystore desde `KEYSTORE_BASE64`
- 📝 Genera `key.properties`

#### Fase 2: Setup y Cache
- ☕ Setup Java 17 (Temurin)
- 📱 Setup Flutter 3.x stable
- 💾 Cache de pub dependencies y Gradle

#### Fase 3: Build
- 🧪 Tests (non-blocking, pueden fallar sin detener build)
- 🔢 Calcula versión dinámica
- 📦 Genera APKs firmados (split por ABI)
- 📦 Genera AAB para Google Play Store

#### Fase 4: Validación Post-Build
- ✅ Verifica que todos los APKs existan
- ✅ Valida tamaños (>1MB cada uno)
- 📊 Lista todos los outputs con tamaños

#### Fase 5: Publicación
- ⬆️ Upload de artifacts (retention: **30 días**)
- 🏷️ Si tag `v*`: Crea GitHub Release automáticamente
- 📋 Build summary en GitHub Actions

**Outputs:**
- 4 APKs firmados para distribución directa
- 1 AAB para Google Play Store
- GitHub Release con todos los assets (si tag `v*`)

## Configuración Inicial

### Paso 1: Generar Keystore de Producción

```bash
cd android/app

# Generar keystore (EC P-384, válido por 10,000 días ~27 años)
keytool -genkey -v -keystore zapar-release.keystore \
  -alias zapar -keyalg EC -keysize 384 -validity 10000

# Responder las preguntas:
# - Password del keystore (anotar)
# - Password de la clave (anotar)
# - Nombre, organización, ciudad, etc.

# Convertir a base64
base64 -w 0 zapar-release.keystore > keystore.b64
cat keystore.b64  # Copiar el contenido
```

### Paso 2: Configurar GitHub Environment

1. Ir a: `Settings → Environments → New environment`
2. Nombre: `PlayStore`
3. Agregar los siguientes **secrets**:

| Secret Name | Valor | Descripción |
|-------------|-------|-------------|
| `KEYSTORE_BASE64` | Contenido de `keystore.b64` | Keystore codificado en base64 |
| `KEYSTORE_PASSWORD` | Password del keystore | Del paso anterior |
| `KEY_ALIAS` | `zapar` | Alias usado en keytool |
| `KEY_PASSWORD` | Password de la clave | Del paso anterior |

4. (Opcional) Configurar `CODECOV_TOKEN` en secrets del repositorio para coverage

### Paso 3: Verificar Configuración

Ejecutar el script de validación:

```bash
.github/scripts/validate_flutter.sh
```

Debería mostrar:
```
✅ All validations passed!
🚀 Project is ready for CI/CD
```

## Versionado

### Formato en pubspec.yaml

```yaml
version: 2.2.5+34
#        ^^^^^  ^^
#          |     |
#          |     +-- Build number (ignorado en CI)
#          +-------- Semantic version (X.Y.Z)
```

### En CI/CD

**Version Name:** Extraído de `pubspec.yaml` (ej: `2.2.5`)

**Version Code:** Calculado dinámicamente
```
VERSION_CODE = BASE_VERSION_CODE + GITHUB_RUN_NUMBER
```

- `BASE_VERSION_CODE` = 100 (configurable en workflow)
- `GITHUB_RUN_NUMBER` = Número de ejecución del workflow

**Ejemplo:**
- Run #45 → `versionCode = 145`

**Version Codes por ABI:**

El `build.gradle` multiplica el `versionCode` por 10 y suma el código ABI:

| ABI | Código | Version Code (ejemplo) |
|-----|--------|----------------------|
| Universal | 0 | 1450 |
| armeabi-v7a | 1 | 1451 |
| arm64-v8a | 2 | 1452 |
| x86 | 3 | 1453 |
| x86_64 | 4 | 1454 |

### Bump de Versión Mayor

Para una versión mayor (ej: `v3.0.0`):

1. Actualizar `pubspec.yaml`:
   ```yaml
   version: 3.0.0+1
   ```

2. (Opcional) Actualizar `BASE_VERSION_CODE` en workflow:
   ```yaml
   env:
     BASE_VERSION_CODE: 200  # Para evitar conflictos con v2.x.x
   ```

## Uso

### Desarrollo Diario (Pull Requests)

```bash
# 1. Crear branch
git checkout -b feature/mi-nueva-feature

# 2. Hacer cambios
# ... código ...

# 3. Commit y push
git add .
git commit -m "feat: agregar nueva funcionalidad"
git push origin feature/mi-nueva-feature

# 4. Crear Pull Request en GitHub
# El workflow se ejecuta automáticamente
```

**Verificar:**
- ✅ Job "Analyze & Test" pasa
- ✅ Job "Build Android Debug APKs" genera artifacts
- 💬 Comentario automático aparece con links de descarga
- 📦 Descargar APKs desde "Artifacts" para testing

### Release de Producción (Manual)

```bash
# 1. Ir a GitHub Actions
# 2. Seleccionar "Production Release Build"
# 3. Click "Run workflow"
# 4. Seleccionar branch (ej: master)
# 5. (Opcional) Marcar "Build iOS app" si es necesario
# 6. Click "Run workflow"
```

**Verificar:**
- ✅ Job completa exitosamente
- 📦 4 APKs + 1 AAB en Artifacts
- 📊 Build summary muestra tamaños

### Release con Tag (Automático)

```bash
# 1. Asegurarse de estar en master actualizado
git checkout master
git pull

# 2. Crear tag
git tag v2.2.6

# 3. Push tag
git push origin v2.2.6

# El workflow se ejecuta automáticamente
```

**Verificar:**
- ✅ Workflow se dispara automáticamente
- 🏷️ GitHub Release se crea
- 📦 APKs renombrados: `zapar-app-v2.2.6-{abi}.apk`
- 📦 AAB incluido: `zapar-app-v2.2.6.aab`
- 📝 Release notes generadas automáticamente

### Instalación de APKs

**Desde Pull Request (Debug):**
```bash
# Descargar APK de Artifacts en GitHub Actions
adb devices
adb install -r app-arm64-v8a-debug.apk
```

**Desde Release (Producción):**
```bash
# Descargar desde GitHub Releases
adb install -r zapar-app-v2.2.6-arm64-v8a.apk
```

**Verificar firma:**
```bash
aapt dump badging zapar-app-v2.2.6-arm64-v8a.apk | grep package
# Debería mostrar: package: name='phanan.koel.app' versionCode='1452' ...
```

## Troubleshooting

### Error: "KEYSTORE_BASE64 secret is not set"

**Causa:** El secret no está configurado en el environment `PlayStore`

**Solución:**
1. Ir a `Settings → Environments → PlayStore`
2. Verificar que existan los 4 secrets requeridos
3. Si faltan, agregarlos siguiendo [Paso 2](#paso-2-configurar-github-environment)

### Error: "Keystore file is too small"

**Causa:** El `KEYSTORE_BASE64` está corrupto o mal codificado

**Solución:**
```bash
# Re-generar el base64
cd android/app
base64 -w 0 zapar-release.keystore > keystore.b64
cat keystore.b64

# Copiar TODO el contenido (sin espacios ni saltos de línea)
# Actualizar el secret en GitHub
```

### Error: "APK is too small"

**Causa:** El build falló silenciosamente

**Solución:**
1. Revisar logs del job "Build release APKs"
2. Buscar errores de compilación
3. Verificar que `key.properties` se creó correctamente
4. Verificar que el signing config en `build.gradle` es correcto

### Tests fallan en PR pero quiero mergear

**Opción 1:** Arreglar los tests (recomendado)

**Opción 2:** Usar admin override (no recomendado)
- Solo si es urgente (hotfix crítico)
- Requiere permisos de admin en el repo

### Cache está corrupto

**Solución:**
```bash
# Eliminar cache manualmente:
# 1. Ir a Actions → Caches
# 2. Eliminar caches problemáticos
# 3. Re-ejecutar workflow
```

O forzar invalidación cambiando key en workflow:
```yaml
key: ${{ runner.os }}-pub-v2-${{ hashFiles('**/pubspec.yaml') }}
#                          ^^^ incrementar número
```

### Workflow tarda demasiado

**Optimizaciones:**

1. Verificar que cache funcione:
   ```
   # En logs, buscar:
   Cache restored from key: ...
   ```

2. Si es primera ejecución, es normal (sin cache)

3. Tiempos esperados:
   - PR workflow: 10-15 min (con cache)
   - Release workflow: 15-25 min (con cache)

## Archivos Importantes

### Workflows
- `.github/workflows/flutter-pr.yml` - Validación de PRs
- `.github/workflows/flutter-release.yml` - Builds de producción
- `.github/workflows/unit.yml.backup` - Workflow antiguo (backup)

### Scripts
- `.github/scripts/validate_flutter.sh` - Validación pre-build

### Configuración Android
- `android/app/build.gradle` - Configuración de signing y versioning
- `android/key.properties` - **NO en repo** (generado en CI)
- `android/app/zapar-release.keystore` - **NO en repo** (generado en CI)

### Versioning
- `pubspec.yaml` - Versión base de la app

## Badges para README

Agregar al `README.md`:

```markdown
[![PR Validation](https://github.com/TU-USERNAME/zapar-app/actions/workflows/flutter-pr.yml/badge.svg)](https://github.com/TU-USERNAME/zapar-app/actions/workflows/flutter-pr.yml)
[![Release Build](https://github.com/TU-USERNAME/zapar-app/actions/workflows/flutter-release.yml/badge.svg)](https://github.com/TU-USERNAME/zapar-app/actions/workflows/flutter-release.yml)
```

## Mejoras Futuras

### Publicación Automática a Google Play

```yaml
- name: Publish to Google Play
  uses: r0adkll/upload-google-play@v1
  with:
    serviceAccountJsonPlainText: ${{ secrets.GOOGLE_PLAY_SERVICE_ACCOUNT }}
    packageName: phanan.koel.app
    releaseFiles: build/app/outputs/bundle/release/app-release.aab
    track: internal
```

### Notificaciones por Email

```yaml
- name: Notify failure
  if: failure()
  uses: dawidd6/action-send-mail@v3
  with:
    server_address: ${{ secrets.EMAIL_SERVER }}
    to: devs@example.com
```

### iOS Builds

- Requiere macOS runner
- Requiere Apple Developer account ($99/año)
- Configurar Fastlane para code signing
- Ver `build-ios-release` job en workflow

## Recursos

- [GitHub Actions Docs](https://docs.github.com/actions)
- [Flutter CI/CD Best Practices](https://docs.flutter.dev/deployment/cd)
- [Android App Signing](https://developer.android.com/studio/publish/app-signing)
- [Codecov](https://about.codecov.io/)

## Soporte

Para problemas con CI/CD:
1. Revisar logs en GitHub Actions
2. Consultar este documento
3. Abrir issue en el repositorio
