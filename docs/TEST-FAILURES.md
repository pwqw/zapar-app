# Tests Rotos

## Problema

`golden_toolkit` **discontinuado** → Tests no compilan

**Estado actual:**
- ❌ Tests completamente rotos
- ❌ 0% coverage real
- ⚠️ Tests configurados como `non-blocking`

## Archivos Afectados

```
test/utils/lrc_parser_test.dart
test/ui/screens/create_playlist_sheet_test.dart
test/ui/widgets/message_overlay_test.dart
test/ui/widgets/oops_box_test.dart
```

## Solución (URGENTE)

```bash
# 1. Remover
# pubspec.yaml: golden_toolkit: ^0.12.0

# 2. Identificar
grep -r "import 'package:golden_toolkit" test/

# 3. Reescribir con flutter_test
# ANTES
import 'package:golden_toolkit/golden_toolkit.dart';
testGoldens('test', (tester) async { ... });

# DESPUÉS
import 'package:flutter_test/flutter_test.dart';
testWidgets('test', (tester) async { ... });

# 4. Verificar
flutter test

# 5. Habilitar blocking
# Remover: continue-on-error: true
```

## Impacto

**Funciona:**
- ✅ Build APK/AAB
- ✅ flutter analyze
- ✅ dart format

**No funciona:**
- ❌ Tests unitarios
- ❌ Coverage
- ❌ Detección de bugs

## Alternativa

Fork no oficial (NO recomendado):
```yaml
golden_toolkit:
  git:
    url: https://github.com/alv-dev/golden_toolkit.git
```
