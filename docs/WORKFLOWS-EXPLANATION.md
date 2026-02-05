# Workflows

## 1. PR Validation (`flutter-pr.yml`)

**Trigger:** Push a master/main/develop

**Jobs:**
- flutter analyze
- dart format
- flutter test + coverage
- Build debug APKs (4 variantes)
- Comentario automático en PR

**Duración:** 10-15 min

---

## 2. Production Build (`flutter-release.yml`)

**Triggers:**
- Manual: `Actions → Run workflow`
- Automático: Tags `v*`

**Fases:**
1. Validación secrets
2. Setup (Java 17, Flutter 3.x)
3. Build APKs + AAB firmados
4. Validación post-build
5. Artifacts (30 días)
6. GitHub Release (tags `v*`)

**Duración:** 20-30 min

---

## Uso

### Desarrollo
```bash
git checkout -b feature/nueva
git push origin feature/nueva
# PR automático
```

### Release Manual
```
GitHub Actions → Production Release Build → Run workflow
```

### Release Tag
```bash
git tag v2.2.7
git push origin v2.2.7
```

---

## Secrets

**Environment:** `PlayStore`

| Secret | Uso |
|--------|-----|
| `KEYSTORE_BASE64` | Keystore en base64 |
| `KEYSTORE_PASSWORD` | Password keystore |
| `KEY_ALIAS` | Alias (zapar) |
| `KEY_PASSWORD` | Password clave |

---

## Versionado

```
VERSION_NAME = pubspec.yaml (ej: 2.2.5)
VERSION_CODE = 100 + GITHUB_RUN_NUMBER
```

---

## Java 17

Flutter 3.38+ requiere Java 17 para compilar.
Output: Java 1.8 bytecode (compatible Android)
