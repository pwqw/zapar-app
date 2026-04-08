# 004 — Documentación de Android App Signing

## Propósito
Documentar la arquitectura de firma de Google Play (upload key vs app signing key), el flujo de CI, y cómo regenerar el keystore si es necesario.

## Archivos afectados
- `docs/ANDROID_APP_SIGNING.md` — Guía completa de signing

## Orden de construcción (desde upstream/master limpio)

1. Crear `docs/ANDROID_APP_SIGNING.md` con las siguientes secciones:

   a. **Arquitectura de llaves de Google Play**:
      - Upload Key: keystore del desarrollador, almacenado en GitHub Secrets
      - App Signing Key: administrada por Google, re-firma antes de distribución
      - Diagrama del flujo: dev firma con upload key → sube AAB → Google re-firma con app signing key → distribuye

   b. **Configuración del keystore**:
      - Algoritmo: RSA 2048 bits
      - Validez: 10000 días
      - Comando para generar: `keytool -genkey -v -keystore zapar.jks -keyalg RSA -keysize 2048 -validity 10000 -alias zapar`
      - Formato de `key.properties`

   c. **GitHub Secrets requeridos**:
      - Lista de secrets con descripción de cada uno
      - Cómo encodear el keystore a base64: `base64 -w 0 zapar.jks`
      - Environment de GitHub: `PlayStore`

   d. **Troubleshooting**:
      - Error de algoritmo incompatible (EC vs RSA)
      - AAB rechazado por Play Store
      - Cómo verificar la firma de un AAB

## Orden de actualización
- Si cambia el flujo de CI (parche 002), actualizar las referencias
- Si Google Play cambia requisitos de firma, actualizar la guía

## Dependencias
Parche 003 (referencia la configuración de gradle).

## Criterio de éxito
- El documento es claro y un nuevo desarrollador puede configurar el signing desde cero siguiéndolo
