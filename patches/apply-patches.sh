#!/bin/bash
set -euo pipefail

# Apply Zapar fork patches over upstream/master
# Usage: ./patches/apply-patches.sh [--check] [--from NNN]

PATCHES_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_DIR="$(dirname "$PATCHES_DIR")"
CHECK_ONLY=false
FROM_PATCH=""

while [[ $# -gt 0 ]]; do
    case $1 in
        --check) CHECK_ONLY=true; shift ;;
        --from)  FROM_PATCH="$2"; shift 2 ;;
        *) echo "Uso: $0 [--check] [--from NNN]"; exit 1 ;;
    esac
done

cd "$REPO_DIR"

# Verificar estado limpio
if [[ -n "$(git status --porcelain)" ]]; then
    echo "ERROR: Working tree no está limpio. Commitear o stashear cambios primero."
    exit 1
fi

echo "=== Zapar Fork Patch System ==="
echo "Directorio: $REPO_DIR"
echo "Rama actual: $(git branch --show-current)"
echo ""

APPLIED=0
FAILED=0

for patch_file in "$PATCHES_DIR"/*.patch; do
    [ -f "$patch_file" ] || continue

    patch_name="$(basename "$patch_file")"
    patch_num="${patch_name%%-*}"

    # Skip parches anteriores a --from
    if [[ -n "$FROM_PATCH" && "$patch_num" < "$FROM_PATCH" ]]; then
        echo "SKIP $patch_name (antes de --from $FROM_PATCH)"
        continue
    fi

    md_file="${patch_file%.patch}.md"

    if $CHECK_ONLY; then
        if git apply --check "$patch_file" 2>/dev/null; then
            echo "  OK  $patch_name"
        else
            echo "FAIL  $patch_name"
            if [ -f "$md_file" ]; then
                echo "      -> Leer $md_file para instrucciones de actualización"
            fi
            FAILED=$((FAILED + 1))
        fi
    else
        echo "Aplicando $patch_name ..."
        if git apply "$patch_file"; then
            git add -A
            # Extraer descripción del .md si existe
            desc="patch: $patch_name"
            if [ -f "$md_file" ]; then
                first_line=$(head -1 "$md_file" | sed 's/^# [0-9]*[[:space:]]*—[[:space:]]*//')
                desc="patch($patch_num): $first_line"
            fi
            git commit -m "$desc"
            echo "  OK  $patch_name"
            APPLIED=$((APPLIED + 1))
        else
            echo ""
            echo "ERROR: $patch_name no aplica limpiamente."
            if [ -f "$md_file" ]; then
                echo "Consultar: $md_file"
            fi
            echo "Resolver el conflicto y luego: $0 --from $patch_num"
            exit 1
        fi
    fi
done

echo ""
if $CHECK_ONLY; then
    if [ $FAILED -eq 0 ]; then
        echo "Todos los parches aplican correctamente."
    else
        echo "$FAILED parche(s) con conflictos."
        exit 1
    fi
else
    echo "$APPLIED parche(s) aplicados exitosamente."
fi
