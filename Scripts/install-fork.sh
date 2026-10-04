#!/bin/bash
# Fork-only: build a signed Release from this checkout and replace /Applications/Tinycast.app.
# The version is the newest upstream tag, so About and the updater compare against a real number.
set -euo pipefail
cd "$(dirname "$0")/.." || exit 1

APP=/Applications/Tinycast.app
BUILT=build/dd/Build/Products/Release/Tinycast.app
VERSION="$(git describe --tags --abbrev=0 --match 'v[0-9]*.[0-9]*.[0-9]*' --exclude '*-*' | sed 's/^v//')"
BUILD_NUMBER="$(git rev-list --count HEAD)"

echo "Building Tinycast $VERSION ($BUILD_NUMBER) from $(git rev-parse --short HEAD)"
xcodebuild -project Tinycast.xcodeproj -scheme Tinycast -configuration Release \
    -derivedDataPath build/dd -quiet \
    MARKETING_VERSION="$VERSION" CURRENT_PROJECT_VERSION="$BUILD_NUMBER" build
./Scripts/verify-signature.sh "$BUILT"

osascript -e 'quit app id "com.tinycast.app"' 2>/dev/null || true
for _ in $(seq 20); do pgrep -f "$APP/Contents/MacOS/Tinycast" >/dev/null || break; sleep 0.5; done

rm -rf "$APP"
ditto "$BUILT" "$APP"
codesign --verify --deep --strict "$APP"
open "$APP"
echo "✓ Installed Tinycast $VERSION ($BUILD_NUMBER)"
