# Optimizaciones CI/CD

## Implementadas

### 1. Cache Pub ANTES de Flutter Setup
```yaml
- Cache pub dependencies  ← Primero
- Setup Flutter           ← Segundo
```

### 2. Key Basado en pubspec.lock
```yaml
key: ${{ runner.os }}-pub-${{ hashFiles('**/pubspec.lock') }}
```

### 3. pub-cache-key Customizado
```yaml
pub-cache-key: ${{ runner.os }}-pub-${{ hashFiles('**/pubspec.lock') }}
```

### 4. Skip pub get si Cache Hit
```yaml
if: steps.flutter-setup.outputs.PUB-CACHE-HIT != 'true'
```

### 5. Cache build_runner
```yaml
path: |
  .dart_tool/build
  **/*.g.dart
```

## Impacto

| Ejecución | Tiempo |
|-----------|--------|
| Primera (sin cache) | 15-20 min |
| Segunda (cache hit) | **5-8 min** ⚡ |
| Cambios menores | 8-12 min |

**Ahorro: ~65%**

## Verificar

**Primera ejecución:**
```
Cache not found for input keys...
Downloading Flutter SDK...
📦 Installing dependencies...
```

**Con cache:**
```
✅ Cache restored from key...
✅ Flutter SDK already cached
✅ Using cached dependencies
```
