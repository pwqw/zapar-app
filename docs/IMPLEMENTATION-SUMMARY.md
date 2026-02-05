# Setup CI/CD - Checklist

## Archivos Creados
- ✅ `.github/workflows/flutter-pr.yml` - PR validation
- ✅ `.github/workflows/flutter-release.yml` - Production builds
- ✅ `.github/scripts/validate_flutter.sh` - Pre-build validation

## Configuración Pendiente

### 1. Keystore
```bash
cd android/app
keytool -genkey -v -keystore zapar-release.keystore \
  -alias zapar -keyalg EC -keysize 384 -validity 10000
base64 -w 0 zapar-release.keystore > keystore.b64
```

### 2. GitHub Secrets
`Settings → Environments → PlayStore`
- `KEYSTORE_BASE64`
- `KEYSTORE_PASSWORD`
- `KEY_ALIAS` = `zapar`
- `KEY_PASSWORD`

### 3. Test PR
```bash
git checkout -b test/ci-workflows
git push origin test/ci-workflows
# Crear PR y verificar
```

### 4. Test Release
```
Actions → Production Release Build → Run workflow
```

### 5. Test Tag
```bash
git tag v2.2.6-test
git push origin v2.2.6-test
```

## Checklist
- [si] Workflows creados
- [si] Docs creados
- [ ] Keystore generado
- [ ] Secrets configurados
- [ ] PR de prueba OK
- [ ] Release manual OK
- [ ] Tag automático OK
