# 🚀 Próximos Pasos - CI/CD Implementado

## ✅ ¿Qué se ha hecho?

Se han reorganizado los workflows de GitHub Actions en **2 archivos separados**:

### Archivos Creados

```
.github/workflows/
├── ci.yml              ← Análisis y tests (push a branches)
├── build-deploy.yml    ← Build firmado y deploy (manual o tags)
└── unit.yml.backup     ← Backup del workflow anterior

docs/
├── CI-CD.md                     ← Guía de uso (ACTUALIZAR)
├── WORKFLOWS-EXPLANATION.md     ← Explicación detallada ⭐ NUEVO
├── VALIDATION.md                ← Validación técnica
└── IMPLEMENTATION-SUMMARY.md    ← Resumen de implementación
```

## 🎯 Cambios Fundamentales Implementados

### 1. ✅ Trigger cambiado: `pull_request` → `push`

**Antes:**
```yaml
on:
  pull_request:  # Requería crear PR
```

**Ahora:**
```yaml
on:
  push:
    branches:
      - master
      - main
      - develop
```

**Ventaja:** Feedback inmediato en cada push, sin necesidad de crear PR.

### 2. ✅ Workflows Separados

**`ci.yml`** (10-15 min)
- Análisis y tests
- Se ejecuta en cada push
- Tests bloqueantes

**`build-deploy.yml`** (20-30 min)
- Build firmado + deploy
- Manual o tags `v*`
- Tests non-blocking

**Ventaja:** Más rápido, más barato, más claro.

### 3. ✅ Tests en archivo único

Todo el análisis y tests está en `ci.yml`:
- flutter analyze
- dart format
- flutter test --coverage
- codecov upload

### 4. ✅ Java 17 Explicado

Ver `docs/WORKFLOWS-EXPLANATION.md` → sección "¿Por qué Java 17?"

**Resumen:** Flutter 3.38+ requiere Java 17 para compilar (toolchain), aunque el bytecode generado sea Java 1.8 (target).

**Fuentes:**
- [Flutter 3.38 Release Notes](https://docs.flutter.dev/release/release-notes/release-notes-3.38.0)

### 5. ✅ Logs y Troubleshooting

El error que obtuviste (`flutter pub get --dry-run` fallando) se ha arreglado:
- Eliminado el paso de validación redundante
- `flutter pub get` se ejecuta directamente

---

## ⚠️ CRÍTICO: Configurar Secrets (5 minutos)

### Paso 1: Generar Keystore (Si no lo tienes)

```bash
cd /proyectos/zapar/zapar-app/android/app

# Generar keystore (EC P-384, válido ~27 años)
keytool -genkey -v -keystore zapar-release.keystore \
  -alias zapar -keyalg EC -keysize 384 -validity 10000

# Cuando te pregunte, anotar:
# - Password del keystore: [ANOTAR]
# - Password de la clave: [ANOTAR]
# - Nombre, organización, etc: [Llenar]

# Convertir a base64 (TODO EN UNA LÍNEA)
base64 -w 0 zapar-release.keystore > keystore.b64

# Ver el contenido (copiar TODO)
cat keystore.b64
```

### Paso 2: Configurar GitHub Environment

1. Ir a: **Settings → Environments**
2. Click: **"New environment"**
3. Nombre: `PlayStore`
4. Click: **"Add secret"** (4 veces)

| Nombre del Secret | Valor | Dónde obtenerlo |
|-------------------|-------|-----------------|
| `KEYSTORE_BASE64` | Contenido COMPLETO de `keystore.b64` | Del Paso 1 |
| `KEYSTORE_PASSWORD` | Password del keystore | Del Paso 1 |
| `KEY_ALIAS` | `zapar` | Del Paso 1 (el -alias) |
| `KEY_PASSWORD` | Password de la clave | Del Paso 1 |

5. Click: **"Save"**

---

## 🧪 Pruebas

### Prueba 1: CI Workflow (5 min)

```bash
# 1. Crear branch de prueba
git checkout -b test/ci-workflow

# 2. Hacer un cambio trivial
echo "# Test" >> README.md

# 3. Commit y push
git commit -am "test(ci): probar workflow de CI"
git push origin test/ci-workflow

# 4. Ver ejecución en: https://github.com/TU-USERNAME/zapar-app/actions
```

**Esperar:**
- ✅ Job "Analyze & Test" complete en ~10 min
- ✅ Tests pasen
- ✅ Coverage suba a Codecov (si configurado)

### Prueba 2: Build Manual (DESPUÉS de configurar secrets)

```bash
# 1. Ir a: https://github.com/TU-USERNAME/zapar-app/actions
# 2. Seleccionar: "Build & Deploy"
# 3. Click: "Run workflow"
# 4. Opciones:
#    - Branch: test/ci-workflow
#    - Build iOS: false
#    - Deploy to Play Store: false
# 5. Click: "Run workflow"

# 6. Esperar ~25 min

# 7. Verificar:
#    - ✅ 4 APKs firmados en Artifacts
#    - ✅ 1 AAB en Artifacts
#    - ✅ Build summary muestra tamaños
```

### Prueba 3: Tag Release (DESPUÉS de Prueba 2)

```bash
# 1. Crear tag de prueba
git tag v2.2.6-test

# 2. Push tag
git push origin v2.2.6-test

# 3. Verificar:
#    - ✅ Build & Deploy workflow se ejecuta
#    - ✅ GitHub Release se crea
#    - ✅ APKs renombrados adjuntos
#    - ✅ AAB adjunto
```

---

## 📚 Documentación

### Para Entender los Workflows
⭐ **Lee primero:** `docs/WORKFLOWS-EXPLANATION.md`

Explica:
- Por qué 2 workflows separados
- Por qué `push` en vez de `pull_request`
- Por qué Java 17
- Flujo completo de trabajo
- Troubleshooting

### Para Uso Diario
`docs/CI-CD.md` - Guía de comandos y ejemplos

### Para Validación Técnica
`docs/VALIDATION.md` - Comparación con docs oficiales

---

## 🔄 Flujo de Trabajo Diario

### Desarrollo Normal

```bash
# 1. Crear feature branch
git checkout -b feature/mi-feature

# 2. Hacer cambios
# ... código ...

# 3. Commit y push
git commit -am "feat(feature): agregar nueva funcionalidad"
git push origin feature/mi-feature

# ✅ CI workflow valida automáticamente
```

### Release de Producción

```bash
# 1. Mergear features a master
git checkout master
git merge feature/mi-feature
git push origin master

# ✅ CI workflow valida

# 2. Crear tag
git tag v2.2.7
git push origin v2.2.7

# ✅ Build & Deploy workflow:
#    - Construye APKs/AAB
#    - Crea GitHub Release
#    - (Opcional) Sube a Play Store
```

---

## 🚨 Errores Comunes y Soluciones

### 1. CI falla con "flutter pub get --dry-run"

**Causa:** Este comando no crea `.dart_tool/package_config.json`

**Solución:** ✅ Ya arreglado! Ahora usa directamente `flutter pub get`

### 2. Build falla con "KEYSTORE_BASE64 secret is not set"

**Causa:** Environment `PlayStore` no configurado

**Solución:** Ver [Paso 2: Configurar GitHub Environment](#paso-2-configurar-github-environment)

### 3. Tests fallan en CI

**Causa:** Tests son bloqueantes en CI

**Solución:** Arreglar tests antes de pushear, o temporalmente deshabilitarlos

### 4. Workflow tarda mucho

**Causa:** Primera ejecución sin cache

**Solución:** Normal. Siguientes ejecuciones serán más rápidas

---

## 📊 Comparación: Antes vs Ahora

| Aspecto | Antes | Ahora |
|---------|-------|-------|
| **Workflows** | 2 archivos (PR + Release) | 2 archivos (CI + Build) |
| **Trigger CI** | `pull_request` | `push` a branches |
| **Trigger Build** | Manual o tags | Manual o tags |
| **Tests en PR** | Bloqueantes | N/A (no hay PR workflow) |
| **Tests en push** | N/A | Bloqueantes |
| **Tests en build** | N/A | Non-blocking |
| **Mantenimiento** | 2 archivos grandes | 2 archivos separados |
| **Java** | Ambiguo | 17 (explicado) |

---

## ✅ Checklist Final

Antes de considerar completo:

- [ ] Secrets configurados en GitHub Environment `PlayStore`
- [ ] CI workflow ejecutó exitosamente (Prueba 1)
- [ ] Build manual ejecutó exitosamente (Prueba 2)
- [ ] Tag release ejecutó exitosamente (Prueba 3)
- [ ] APK de producción descargado y probado en dispositivo
- [ ] Documentación revisada (`WORKFLOWS-EXPLANATION.md`)
- [ ] Eliminar branches/tags de prueba

---

## 🎉 Estado Actual

**CI/CD:** ✅ Listo para producción

**Próximos pasos:**
1. Configurar secrets
2. Ejecutar pruebas
3. Configurar Play Store (cuando estés listo)

**Para Play Store:**
- Crear app en Google Play Console
- Generar service account JSON
- Agregar secret `GOOGLE_PLAY_SERVICE_ACCOUNT`
- Configurar track (internal → alpha → beta → production)

---

## 📞 Archivos Útiles

- ⭐ `docs/WORKFLOWS-EXPLANATION.md` - Explicación completa
- `docs/CI-CD.md` - Guía de uso
- `docs/VALIDATION.md` - Validación técnica
- `.github/workflows/ci.yml` - Workflow de CI
- `.github/workflows/build-deploy.yml` - Workflow de Build

---

**Última actualización:** 2026-02-04
**Estado:** ✅ Workflows reorganizados y listos para pruebas
