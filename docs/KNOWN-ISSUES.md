# Issues Conocidos

## 1. golden_toolkit Discontinuado

**Problema:** Tests no compilan (Flutter 3.38.9 incompatible)

**Archivos afectados:**
```
test/utils/lrc_parser_test.dart
test/ui/screens/create_playlist_sheet_test.dart
test/ui/widgets/message_overlay_test.dart
test/ui/widgets/oops_box_test.dart
```

**Estado:** Tests configurados como `non-blocking` en CI

**Solución URGENTE:**
```bash
# 1. Remover de pubspec.yaml
# golden_toolkit: ^0.12.0

# 2. Identificar usos
grep -r "golden_toolkit" test/

# 3. Reescribir con flutter_test

# 4. Verificar
flutter test

# 5. Habilitar tests blocking en workflows
```

---

## 2. build_runner Falla (Mockito Desactualizado)

**Problema:** Analyzer 7.4.5 vs requerido 10.0.2

**Archivos afectados:**
```
test/ui/widgets/simple_song_list_test.dart
test/ui/widgets/footer_player_sheet_test.dart
test/ui/widgets/song_card_test.dart
test/ui/widgets/song_list_buttons_test.dart
```

**Estado:** `build_runner` configurado como `non-blocking`

**Solución:**
```yaml
# pubspec.yaml
dev_dependencies:
  analyzer: ^10.0.2
  mockito: ^5.6.3
```

```bash
flutter pub upgrade
flutter pub run build_runner build --delete-conflicting-outputs
flutter test
```

---

## 3. Packages Desactualizados

**Críticos:**
- `golden_toolkit` - **discontinued** ⚠️
- `analyzer` 7.4.5 → 10.0.2
- `mockito` 5.4.6 → 5.6.3

**Comando:**
```bash
flutter pub outdated --show-all
```

**Prioridades:**
1. Remover golden_toolkit
2. Actualizar analyzer y mockito
3. Upgrade completo de dependencias

---

## Checklist Mantenimiento

### URGENTE
- [ ] Remover golden_toolkit
- [ ] Reescribir tests afectados
- [ ] Habilitar tests blocking

### Trimestral
- [ ] `flutter pub outdated --show-all`
- [ ] Actualizar dev dependencies
- [ ] Regenerar mocks
- [ ] Verificar deprecated packages
