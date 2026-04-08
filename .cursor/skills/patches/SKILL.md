---
name: patches
description: Mantiene el fork Zapar sobre koel/player. Aplica, verifica, regenera y crea parches en patches/. Usar al trabajar con patches del repo Flutter, upstream/master, git apply, o cuando el usuario mencione parches Zapar/koel.
---

# patches — Mantenimiento del fork Zapar

**Asunción**: `origin/master` y `upstream/master` ya están actualizados.

**Working directory**: raíz de este repositorio (`app`). Todos los comandos `git`, `flutter` y rutas `patches/` se ejecutan aquí.

## Contexto actual

```bash
echo "=== Branch ===" && git branch --show-current && echo "=== Patches ===" && ls patches/*.patch 2>/dev/null | sort && echo "=== Estado ===" && git status --short
```

## Subcomando

Interpretar la petición del usuario como uno de:

| Argumento / intención | Acción |
|----------------------|--------|
| (ninguno / flujo completo) | Aplicar → verificar → proponer tag |
| `status` | Estado sin modificar nada |
| `check` | Dry-run de cada parche sobre el estado actual |
| `update <NNN>` | Regenerar parche NNN desde el working tree |
| `new <nombre>` | Nuevo parche + `.md` desde cambios actuales |

Detalle: [reference.md](reference.md).

---

## Flujo completo

### 1 — Aplicar parches

Para cada `patches/*.patch` en orden numérico:

```bash
git apply --check patches/NNN-nombre.patch
git apply patches/NNN-nombre.patch
```

Si falla: leer `patches/NNN-nombre.md` (fuente de verdad), alinear con upstream, actualizar el `.patch`. No omitir ningún parche.

### 2 — Verificar

- `flutter analyze` sin errores nuevos
- `flutter build web` (incluye validación del parche 005 si aplica)
- Si existe `patches/tests/`: `flutter test patches/tests/`

Reportar qué parches pasan y advertencias.

### 3 — Proponer tag

```bash
git tag --list 'v*' --sort=-v:refname | head -1
```

Proponer `vX.Y.Z-patched` y **esperar confirmación** antes de:

```bash
git tag -a vX.Y.Z-patched -m "Zapar fork — upstream + patches aplicados"
git push origin vX.Y.Z-patched
```

---

## Invariantes

- `upstream/master` no se reescribe localmente
- El `.md` manda sobre el `.patch` si hay conflicto de interpretación
- Parche que no aplica → actualizar, no saltar
- Tags con sufijo `-patched`
- Nunca `push` del tag sin confirmación explícita
