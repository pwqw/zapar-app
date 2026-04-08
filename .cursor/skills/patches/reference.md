# Referencia de subcomandos — patches

**Base**: raíz del repo `app` (directorio `patches/`).

## `status`

```bash
git log upstream/master..HEAD --oneline
git tag --list 'v*' --sort=-v:refname | head -1
ls patches/*.patch 2>/dev/null | sort
git status --short
```

Reportar:

- Commits por delante de upstream que no correspondan a flujo de parches (posible trabajo manual)
- Parches posiblemente desactualizados respecto al working tree

---

## `check`

Por cada `patches/*.patch`:

```bash
git apply --check patches/NNN-nombre.patch
```

Resumen: cuáles aplicarían limpio y cuáles fallarían. Luego `flutter analyze` y errores relevantes.

---

## `update <NNN>`

Regenerar el parche NNN desde el working tree actual.

1. Leer `patches/NNN-nombre.md` para archivos cubiertos
2. Generar `.patch`:

```bash
git diff upstream/master -- <archivos-del-parche> > patches/NNN-nombre.patch
```

3. `git apply --check patches/NNN-nombre.patch`
4. Resumir cambios respecto al parche anterior y si el `.md` sigue siendo preciso

---

## `new <nombre>`

Parche para cambios no cubiertos por parches existentes.

1. `git diff upstream/master --name-only`
2. Excluir archivos ya listados en `.md` existentes
3. Generar:

```bash
git diff upstream/master -- <archivos-nuevos> > patches/NNN-<nombre>.patch
```

4. Crear `patches/NNN-<nombre>.md`:

```markdown
# Parche NNN — <nombre>

## Propósito
[Por qué Zapar necesita este parche]

## Archivos modificados
- `ruta/archivo.ext` — [descripción del cambio]

## Actualización
[Qué revisar cuando upstream toca estos archivos]

## Criterio de éxito
- [ ] `git apply --check` pasa limpio
- [ ] [verificación específica]
```

5. NNN = último número existente + 1
6. Entrada en `patches/README.md`
