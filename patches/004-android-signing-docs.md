# 004 — Documentación Android signing

Añade `docs/ANDROID_APP_SIGNING.md` con el flujo Play Store (upload key vs app signing key), ejemplos de `keytool` y tabla de GitHub Secrets alineada con el package por defecto de Koel (`phanan.koel.app`).

Detalle para el índice del PR:

- [ ] Documento enlazado desde README del fork si aplica
- [ ] Comando keystore de ejemplo: `keytool -genkey -v -keystore koel-upload.jks ... -alias koel`
- [ ] Codificación base64 del keystore para CI
- [ ] Referencia a `.env` / `local.properties` para otro `applicationId`
