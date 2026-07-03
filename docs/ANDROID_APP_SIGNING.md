# Android App Signing - Koel

## Overview

Google Play Store usa **dos llaves distintas** en la arquitectura de firma:

### Upload Key (nuestra)
- Keystore del desarrollador, almacenado en GitHub Secrets
- Usada para firmar el AAB que sube el CI
- **DEBE mantenerse privada y segura**

### App Signing Key (Google)
- Administrada por Google Play
- Re-firma el APK antes de distribuirlo a usuarios
- Aumenta seguridad: aunque la upload key se comprometa, el APK final tiene la app signing key de Google

## Arquitectura de Flujo

```
Dev keystore (upload key)
       ↓
CI firma AAB con upload key
       ↓
GitHub Actions sube AAB a Play Store
       ↓
Google Play Server re-firma con su app signing key
       ↓
APK firmado listo para distribución
```

## Configuración del Keystore

### Generar un nuevo keystore

```bash
keytool -genkey -v -keystore koel-upload.jks \
  -keyalg RSA \
  -keysize 2048 \
  -validity 10000 \
  -alias koel
```

**Parámetros importantes:**
- **keyalg: RSA** (IMPORTANTE: Google Play rechaza EC keys)
- **keysize: 2048** (mínimo recomendado)
- **validity: 10000** (~27 años, cubre vida del proyecto)

### Codificar para GitHub Secrets

```bash
base64 -w 0 koel-upload.jks > keystore-base64.txt
```

## Package name (applicationId)

Por defecto coincide con upstream: `phanan.koel.app`. Para un build con otro id (p. ej. Play Store propio), sin commitear secretos:

1. **`android/local.properties`** (gitignored en `android/.gitignore`): `android.applicationId=com.tuempresa.tuapp`
2. O raíz **`.env`** (gitignored): `ANDROID_APPLICATION_ID=com.tuempresa.tuapp` (ver `.env.example`).

## GitHub Secrets Requeridos

Environment: `PlayStore`

| Secret | Descripción | Ejemplo |
|--------|-------------|---------|
| `KEYSTORE_BASE64` | Keystore codificado en base64 | (output de base64) |
| `KEYSTORE_PASSWORD` | Contraseña del keystore | `supersecret123` |
| `KEY_ALIAS` | Alias de la clave | `koel` |
| `KEY_PASSWORD` | Contraseña de la clave | `supersecret456` |
| `PACKAGE_NAME` | Package name de la app | `phanan.koel.app` |
| `GOOGLE_PLAY_SERVICE_ACCOUNT` | JSON del service account de Play Store | (JSON completo) |

## Verificar la Firma de un AAB

```bash
# Listar signatarios
jarsigner -verify -verbose -certs build/app/outputs/bundle/release/app-release.aab

# Verificar contra un keystore
jarsigner -verify -keystore koel-upload.jks build/app/outputs/bundle/release/app-release.aab
```

## Troubleshooting

- **"Keystore algorithm RSA2048 not compatible"**: El keystore usa EC en lugar de RSA. Generar uno nuevo.
- **"AAB rejected by Play Store"**: Verificar que el certificado no haya expirado y que el package name coincida.
