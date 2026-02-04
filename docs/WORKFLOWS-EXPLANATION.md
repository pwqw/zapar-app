# Explicación de Workflows - Zapar App

## 📋 Estructura de Workflows

El proyecto utiliza **2 workflows separados** para maximizar eficiencia y claridad:

### 1. `ci.yml` - Continuous Integration (Análisis y Tests)
### 2. `build-deploy.yml` - Build & Deploy (Construcción y Distribución)

---

## 🔍 1. CI Workflow (`ci.yml`)

### Propósito
Validación rápida de código en cada push a branches principales.

### Trigger
```yaml
on:
  push:
    branches:
      - master
      - main
      - develop
```

**¿Por qué `push` y no `pull_request`?**

El disparador `on: push` es más apropiado porque:

1. **Feedback inmediato**: Se ejecuta cuando haces push, no necesitas crear un PR
2. **Desarrollo ágil**: Valida código en feature branches sin ceremonias
3. **Menos fricción**: Útil para repos donde se hace commit directo a develop/master
4. **Compatible con PRs**: GitHub ejecuta el workflow automáticamente cuando un PR actualiza el branch

**Flujo típico:**
```bash
git checkout -b feature/nueva-feature
# ... cambios ...
git commit -m "feat: nueva feature"
git push origin feature/nueva-feature
# ✅ CI workflow se ejecuta automáticamente
```

### Jobs

**`analyze-and-test`** (20 min timeout)
- ✅ Flutter analyze
- ✅ Dart format check
- ✅ Unit tests con coverage
- ✅ Upload a Codecov

### Características
- **Bloqueante**: Si falla, sabes que hay un problema
- **Rápido**: Solo análisis y tests, sin builds pesados
- **Cache**: Flutter SDK + pub dependencies

### Cuándo se ejecuta
- ✅ Push a `master`, `main`, o `develop`
- ✅ Push a cualquier branch (si configurado)
- ✅ Automáticamente en PRs que apuntan a esos branches

---

## 🚀 2. Build & Deploy Workflow (`build-deploy.yml`)

### Propósito
Construir APKs/AAB firmados y opcionalmente desplegarlos a Play Store.

### Triggers
```yaml
on:
  workflow_dispatch:  # Manual
    inputs:
      build_ios: ...
      deploy_to_playstore: ...
      track: ...
  push:
    tags:
      - 'v*'          # Automático con tags
```

**Dos formas de ejecutar:**

#### A. Manual (`workflow_dispatch`)
```bash
# En GitHub: Actions → Build & Deploy → Run workflow
# Opciones:
# - Build iOS? (true/false)
# - Deploy to Play Store? (true/false)
# - Track: internal/alpha/beta/production
```

#### B. Automático (tags `v*`)
```bash
git tag v2.2.6
git push origin v2.2.6
# ✅ Workflow se ejecuta automáticamente
# ✅ Crea GitHub Release
# ✅ (Opcional) Sube a Play Store si está configurado
```

### Jobs

#### `build-android` (60 min timeout)

**FASE 1: Validación Temprana (Fail Fast)**
- 🔐 Valida secrets del environment `PlayStore`
- 🔑 Crea keystore desde base64
- 📝 Genera `key.properties`

**FASE 2: Setup y Cache**
- ☕ Java 17 (Temurin)
- 📱 Flutter 3.x stable
- 💾 Cache de pub + Gradle

**FASE 3: Build**
- 🧪 Tests (non-blocking, pueden fallar)
- 🔢 Calcula versión dinámica
- 📦 Build APKs (4 variantes)
- 📦 Build AAB para Play Store

**FASE 4: Validación Post-Build**
- ✅ Verifica existencia de archivos
- ✅ Valida tamaños (>1MB)

**FASE 5: Artifacts**
- ⬆️ Upload APKs (retention: 30 días)
- ⬆️ Upload AAB (retention: 30 días)

**FASE 6: GitHub Release** (solo tags `v*`)
- 🏷️ Crea release con APKs renombrados
- 📝 Genera release notes

**FASE 7: Deploy a Play Store** (opcional)
- 🚀 Sube AAB a Play Store
- 📊 Track configurable (internal/alpha/beta/production)

**FASE 8: Build Summary**
- 📊 Resumen en GitHub Actions UI

#### `build-ios` (60 min timeout, opcional)
- Solo si `build_ios: true` en workflow_dispatch
- Placeholder para builds de iOS futuro

---

## ❓ ¿Por qué Java 17?

Tu proyecto usa **Java 1.8** (build.gradle:36-37):
```gradle
compileOptions {
    sourceCompatibility JavaVersion.VERSION_1_8
    targetCompatibility JavaVersion.VERSION_1_8
}
```

**Pero el CI usa Java 17. ¿Por qué?**

### Respuesta: Requisito de Flutter 3.38+

Según la [documentación oficial de Flutter 3.38](https://docs.flutter.dev/release/release-notes/release-notes-3.38.0):

> **Flutter 3.38 requires Java 17** as the minimum version for Android, matching the Gradle 8.14 minimum requirement.

### Desglose Técnico

| Componente | Versión Requerida | Motivo |
|-----------|-------------------|--------|
| **Flutter 3.38+** | Java 17 mínimo | Requisito oficial desde Nov 2025 |
| **Gradle 8.14** | Java 17 mínimo | Usado por Flutter 3.38 |
| **Android Gradle Plugin 8.11** | Java 17 mínimo | Compatibilidad con Gradle 8.14 |
| **Tu código (compileOptions)** | Java 1.8 (compatibilidad) | Bytecode generado |

### ¿Cómo funciona?

```
Java 17 (toolchain) → Compila → Java 1.8 bytecode (output)
         ↑                              ↓
    CI/CD runner                  APK compatible con
                                  Android desde API 21+
```

**Analogía:**
- Es como usar GCC 12 (compilador moderno) para generar código compatible con C99 (estándar antiguo)
- El **toolchain** (Java 17) es más nuevo que el **target** (Java 1.8)

### Conclusión

✅ **Java 17 es CORRECTO** porque:
1. Flutter 3.38+ lo requiere para **compilar** (toolchain)
2. Tu app seguirá corriendo en Android con Java 1.8 bytecode (target)
3. Es el estándar actual de la industria (2025-2026)

### Fuentes
- [Flutter 3.38 Release Notes](https://docs.flutter.dev/release/release-notes/release-notes-3.38.0)
- [Android Java Gradle Migration Guide](https://docs.flutter.dev/release/breaking-changes/android-java-gradle-migration-guide)

---

## 🔄 Flujo Completo de Trabajo

### Desarrollo Diario

```bash
# 1. Crear feature branch
git checkout -b feature/nueva-funcionalidad

# 2. Hacer cambios
# ... código ...

# 3. Commit y push
git commit -am "feat(feature): agregar nueva funcionalidad"
git push origin feature/nueva-funcionalidad

# ✅ CI workflow se ejecuta automáticamente
# - Valida análisis
# - Ejecuta tests
# - Reporta en GitHub
```

### Pre-Release (opcional)

```bash
# Ejecutar build manual para probar
# En GitHub: Actions → Build & Deploy → Run workflow
# - Branch: feature/nueva-funcionalidad
# - Deploy to Play Store: false
# - Revisar artifacts generados
```

### Release de Producción

```bash
# 1. Mergear feature a master
git checkout master
git merge feature/nueva-funcionalidad
git push origin master

# ✅ CI workflow valida el merge

# 2. Crear tag de versión
git tag v2.2.7
git push origin v2.2.7

# ✅ Build & Deploy workflow:
#    - Construye APKs/AAB firmados
#    - Crea GitHub Release
#    - (Opcional) Sube a Play Store
```

---

## 🎯 Comparación: `ci.yml` vs `build-deploy.yml`

| Aspecto | `ci.yml` | `build-deploy.yml` |
|---------|----------|-------------------|
| **Trigger** | `push` a branches | Manual o tags `v*` |
| **Frecuencia** | Cada push | Bajo demanda / releases |
| **Duración** | 10-15 min | 20-30 min |
| **Tests** | ✅ Bloqueantes | ⚠️ Non-blocking |
| **Builds** | ❌ No | ✅ APKs + AAB firmados |
| **Signing** | ❌ No requiere | ✅ Requiere secrets |
| **Artifacts** | ❌ No | ✅ APKs + AAB (30 días) |
| **GitHub Release** | ❌ No | ✅ Para tags `v*` |
| **Play Store** | ❌ No | ✅ Opcional |
| **Propósito** | Validación rápida | Distribución |

---

## 🔐 Secrets Requeridos

### Para `ci.yml`
- `CODECOV_TOKEN` (opcional, para coverage)

### Para `build-deploy.yml`
En el environment `PlayStore`:

| Secret | Descripción |
|--------|-------------|
| `KEYSTORE_BASE64` | Keystore codificado en base64 |
| `KEYSTORE_PASSWORD` | Password del keystore |
| `KEY_ALIAS` | Alias de la clave (ej: `zapar`) |
| `KEY_PASSWORD` | Password de la clave privada |
| `GOOGLE_PLAY_SERVICE_ACCOUNT` | JSON del service account (opcional, para deploy) |

---

## 📊 Versionado Dinámico

```yaml
VERSION_NAME = pubspec.yaml version (ej: 2.2.5)
VERSION_CODE = BASE_VERSION_CODE (100) + GITHUB_RUN_NUMBER

# Ejemplo:
# - Run #45 → versionCode = 145
# - build.gradle multiplica por 10 y suma ABI code
#   - Universal: 1450
#   - arm64-v8a: 1452
#   - armeabi-v7a: 1451
#   - x86: 1453
#   - x86_64: 1454
```

---

## 🚨 Troubleshooting

### CI falla por tests
**Causa:** Tests deben pasar (bloqueantes)
**Solución:** Arreglar tests antes de pushear

### Build & Deploy falla por secrets
**Causa:** Environment `PlayStore` no configurado
**Solución:** Ver `docs/CI-CD.md` → Configuración Inicial

### Workflow tarda mucho
**Causa:** Primera ejecución (sin cache)
**Solución:** Normal. Siguientes ejecuciones: 10-15 min (CI), 20-30 min (Build)

### ¿Por qué dos workflows separados?

**Ventajas:**
1. **Velocidad**: CI rápido (solo tests) vs Build pesado (solo cuando necesario)
2. **Costos**: Menos minutos de GitHub Actions consumidos
3. **Claridad**: Responsabilidades separadas
4. **Flexibilidad**: Ejecutar builds sin esperar tests completos
5. **Mantenimiento**: Más fácil modificar uno sin afectar el otro

**Alternativa descartada: Un solo workflow**
- ❌ Más lento (siempre hace build)
- ❌ Más complejo (muchos condicionales)
- ❌ Mayor costo en runners
- ❌ Menos flexible

---

## 📚 Archivos Relacionados

- `docs/CI-CD.md` - Guía de uso completa
- `docs/VALIDATION.md` - Validación contra docs oficiales
- `NEXT-STEPS.md` - Guía de configuración inicial

---

**Última actualización:** 2026-02-04
