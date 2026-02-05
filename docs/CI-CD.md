# CI/CD - Guía Rápida

## Workflows
- **PR Validation** (`.github/workflows/flutter-pr.yml`) - Tests automáticos en PRs
- **Production Build** (`.github/workflows/flutter-release.yml`) - Builds firmados

## Setup Inicial

### 1. Generar Keystore
```bash
cd android/app
keytool -genkey -v -keystore zapar-release.keystore \
  -alias zapar -keyalg EC -keysize 384 -validity 10000

base64 -w 0 zapar-release.keystore > keystore.b64
cat keystore.b64
```

### 2. GitHub Environment

**Crear:** `Settings → Environments → PlayStore`

**Secrets requeridos:**
| Secret | Valor |
|--------|-------|
| `KEYSTORE_BASE64` | Contenido de `keystore.b64` |
| `KEYSTORE_PASSWORD` | Password del keystore |
| `KEY_ALIAS` | `zapar` |
| `KEY_PASSWORD` | Password de la clave |
| `CODECOV_TOKEN` | Token de Codecov (opcional) |

### 3. Validar
```bash
.github/scripts/validate_flutter.sh
```

## Versionado

```yaml
# pubspec.yaml
version: 2.2.5+34
#        ^^^^^  Version name (usado en CI)
```

**Version Code:** `100 + GITHUB_RUN_NUMBER`

## Uso

### PR Workflow (Automático)
```bash
git checkout -b feature/nueva-feature
git push origin feature/nueva-feature
# Crear PR → Workflow automático
```

### Release Manual
```
GitHub Actions → Production Release Build → Run workflow
```

### Release con Tag
```bash
git tag v2.2.6
git push origin v2.2.6
# Crea GitHub Release automáticamente
```

## Troubleshooting

**Error:** "KEYSTORE_BASE64 secret is not set"
→ Verificar secrets en environment `PlayStore`

**Error:** "Keystore file is too small"
→ Re-generar base64: `base64 -w 0 zapar-release.keystore`

**Tests fallan en PR**
→ Arreglar tests (son bloqueantes)

**Cache corrupto**
→ `Actions → Caches → Eliminar`
