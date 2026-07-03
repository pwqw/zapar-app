# 003 — Android applicationId (override local)

Mantiene el valor por defecto de upstream (`phanan.koel.app`). Permite otro package sin tocar el repo:

- `android/local.properties` → `android.applicationId=...`
- Raíz `.env` → `ANDROID_APPLICATION_ID=...` (ver `.env.example`)

La firma con `key.properties` y `signingConfigs` **ya está** en `upstream/master`; este parche solo añade la resolución del id.
