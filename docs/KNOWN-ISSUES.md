# Issues Conocidos - CI/CD

## 1. Build Runner Falla por Mockito Desactualizado

### Síntoma
```
[SEVERE] mockito:mockBuilder on test/ui/widgets/simple_song_list_test.dart:
Invalid @GenerateMocks annotation: The GenerateMocks "classes" argument is missing,
includes an unknown type, or includes an extension

Failed after 22.7s
```

### Causa Raíz

**Analyzer desactualizado:**
- Versión actual: `7.4.5`
- Versión requerida: `10.0.2`
- SDK language version: `3.10.0`
- Analyzer language version: `3.9.0`

**Archivos afectados:**
```
test/ui/widgets/simple_song_list_test.dart
test/ui/widgets/footer_player_sheet_test.dart
test/ui/widgets/song_card_test.dart
test/ui/widgets/song_list_buttons_test.dart
```

### Estado Actual en CI/CD

**Solución temporal:** `build_runner` configurado como **non-blocking**

```yaml
- name: Run build_runner
  continue-on-error: true  ← No bloquea el workflow
  run: |
    flutter pub run build_runner build --delete-conflicting-outputs || {
      echo "⚠️ build_runner failed but continuing"
      exit 0
    }
```

**Impacto:**
- ✅ CI/CD continúa funcionando
- ⚠️ Archivos `.g.dart` de mocks NO se regeneran
- ⚠️ Si cambias los mocks, debes generarlos localmente

### Solución Permanente (TODO)

#### Opción A: Actualizar Analyzer (Recomendado)

```yaml
# pubspec.yaml
dev_dependencies:
  analyzer: ^10.0.2  # Agregar versión específica
  mockito: ^5.6.3    # Actualizar a última versión
```

**Pasos:**
1. Agregar constraint de analyzer en `pubspec.yaml`
2. Ejecutar `flutter pub upgrade`
3. Regenerar mocks: `flutter pub run build_runner build --delete-conflicting-outputs`
4. Verificar que tests pasen
5. Commit y push

**Riesgo:** Puede requerir cambios en código de tests si hay breaking changes.

#### Opción B: Remover Mocks Problemáticos

Si no estás usando los mocks en esos 4 archivos, puedes:

1. Eliminar las annotations `@GenerateMocks([...])`
2. Eliminar imports de archivos `.mocks.dart`
3. Regenerar: `flutter pub run build_runner build --delete-conflicting-outputs`

**Riesgo:** Tests dejarán de funcionar si usan esos mocks.

#### Opción C: Downgrade SDK (No recomendado)

Usar Flutter SDK más antiguo compatible con analyzer 7.4.5.

**Riesgo:** Pierdes features y fixes de Flutter 3.38+

### Recomendación

**Para producción inmediata:**
- ✅ Dejar `build_runner` como non-blocking (ya configurado)
- ✅ CI/CD funciona sin problemas

**Para largo plazo:**
- 📋 Agendar tarea: Actualizar analyzer y mockito
- 📋 Ejecutar localmente: `flutter pub outdated`
- 📋 Planificar upgrade de dependencias (61 packages desactualizados)

---

## 2. 61 Packages Desactualizados

### Síntoma
```
1 package is discontinued.
61 packages have newer versions incompatible with dependency constraints.
Try `flutter pub outdated` for more information.
```

### Packages Críticos Desactualizados

| Package | Actual | Disponible | Tipo |
|---------|--------|------------|------|
| `golden_toolkit` | 0.12.0 | discontinued ⚠️ | Test |
| `analyzer` | 7.4.5 | 10.0.2 | Dev |
| `mockito` | 5.4.6 | 5.6.3 | Dev |
| `build_runner` | 2.4.14 | 2.10.5 | Dev |
| `http` | 0.13.6 | 1.6.0 | Prod |
| `just_audio` | 0.9.46 | 0.10.5 | Prod |

### Impacto en CI/CD

**Actual:**
- ✅ Builds funcionan
- ⚠️ build_runner falla (non-blocking)
- ⚠️ Warnings de versiones en logs

**Futuro:**
- ⚠️ Posibles breaking changes si Flutter SDK actualiza
- ⚠️ Vulnerabilidades de seguridad potenciales
- ⚠️ Incompatibilidades con nuevas APIs

### Solución

**Estrategia de upgrade:**

1. **Fase 1: Dev dependencies (bajo riesgo)**
   ```bash
   flutter pub upgrade analyzer
   flutter pub upgrade mockito
   flutter pub upgrade build_runner
   flutter test  # Verificar que no rompe tests
   ```

2. **Fase 2: Production dependencies (alto riesgo)**
   ```bash
   flutter pub upgrade http
   flutter pub upgrade just_audio
   # Probar app completamente antes de commit
   ```

3. **Fase 3: Deprecated packages**
   ```bash
   # golden_toolkit está discontinuado
   # Evaluar alternativa o remover
   ```

**Comando útil:**
```bash
flutter pub outdated --show-all
```

### Recomendación

**Inmediato:**
- ✅ Ignorar warnings (no bloquean funcionamiento)

**Corto plazo (1-2 semanas):**
- 📋 Ejecutar `flutter pub outdated`
- 📋 Crear plan de upgrade
- 📋 Actualizar dev dependencies primero

**Largo plazo:**
- 📋 Establecer schedule trimestral de dependency upgrades
- 📋 Usar Dependabot (opcional)

---

## 3. Dependencias de Git (native_qr)

### Síntoma
```yaml
native_qr:
  git:
    url: https://github.com/roman-yerin/native_qr.git
    ref: 8d84d3706f53594d40a47c15b49cf19f41d075be
```

### Riesgo

- ⚠️ Dependencia de un commit específico (no tag/versión)
- ⚠️ Si el repo desaparece, el build falla
- ⚠️ No se actualiza automáticamente con `pub upgrade`

### Solución

**Monitorear:**
```bash
# Revisar si hay nueva versión publicada
flutter pub outdated

# Revisar repo upstream
# https://github.com/roman-yerin/native_qr/pulls/5
```

**Si el PR #5 se mergea:**
```yaml
# Cambiar a versión de pub.dev
native_qr: ^1.0.0  # O la versión publicada
```

---

## 📋 Checklist de Mantenimiento

### Mensual
- [ ] Revisar logs de CI/CD por nuevos warnings
- [ ] Ejecutar `flutter pub outdated`

### Trimestral
- [ ] Actualizar dev dependencies
- [ ] Regenerar mocks si analyzer actualizado
- [ ] Probar suite completa de tests

### Semestral
- [ ] Evaluar actualización de production dependencies
- [ ] Revisar deprecated packages
- [ ] Actualizar Flutter SDK si hay LTS nueva

---

## 🔗 Referencias

- [Flutter Dependency Management](https://docs.flutter.dev/development/packages-and-plugins/using-packages)
- [Mockito Documentation](https://pub.dev/packages/mockito)
- [Build Runner Guide](https://pub.dev/packages/build_runner)

---

**Última actualización:** 2026-02-04
**Estado:** build_runner non-blocking, CI/CD funcional
