#!/usr/bin/env bash
set -e

echo "=== OnionSure Android APK Build Script ==="

# Check Flutter installation
if ! command -v flutter &> /dev/null; then
    echo "Error: 'flutter' command not found in PATH."
    exit 1
fi

echo "1. Fetching dependencies..."
flutter pub get

echo "2. Building Debug APK..."
flutter build apk --debug

echo "3. Building Release APK..."
flutter build apk --release

echo ""
echo "=== Build Completed! ==="
echo "Debug APK located at:   build/app/outputs/flutter-apk/app-debug.apk"
echo "Release APK located at: build/app/outputs/flutter-apk/app-release.apk"
