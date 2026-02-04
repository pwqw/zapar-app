#!/bin/bash
set -e

echo "🔍 Validating Flutter project..."
echo ""

# Validar pubspec.yaml
echo "📋 Checking pubspec.yaml..."
flutter pub get --dry-run || {
    echo "❌ pubspec.yaml validation failed"
    exit 1
}
echo "✅ pubspec.yaml is valid"
echo ""

# Verificar dependencias críticas
echo "📦 Checking critical dependencies..."
critical_deps=("audio_service" "just_audio" "native_qr" "build_runner")

for dep in "${critical_deps[@]}"; do
    if grep -q "$dep:" pubspec.yaml; then
        echo "  ✅ $dep found"
    else
        echo "  ❌ Missing critical dependency: $dep"
        exit 1
    fi
done
echo ""

# Verificar estructura de directorios Android
echo "🤖 Checking Android structure..."
required_files=(
    "android/app/build.gradle"
    "android/build.gradle"
    "android/settings.gradle"
)

for file in "${required_files[@]}"; do
    if [ -f "$file" ]; then
        echo "  ✅ $file exists"
    else
        echo "  ❌ Missing required file: $file"
        exit 1
    fi
done
echo ""

# Verificar versión en pubspec.yaml
echo "🔢 Checking version..."
version=$(grep "^version:" pubspec.yaml | cut -d' ' -f2)
if [ -n "$version" ]; then
    echo "  ✅ Version found: $version"
else
    echo "  ❌ Version not found in pubspec.yaml"
    exit 1
fi
echo ""

echo "✅ All validations passed!"
echo "🚀 Project is ready for CI/CD"
