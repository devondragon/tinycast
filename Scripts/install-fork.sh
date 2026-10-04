#!/bin/bash
# Fork-only: build a signed Release from this checkout and replace /Applications/Tinycast.app.
# The version is the newest upstream tag, so About and the updater compare against a real number.
set -euo pipefail
cd "$(dirname "$0")/.." || exit 1

APP=/Applications/Tinycast.app
STAGED=/Applications/Tinycast.app.installing
BUILT=build/dd/Build/Products/Release/Tinycast.app
IDENTITY="Tinycast Self-Signed"

# Without `-v`: a self-signed identity is listed, but not counted as valid for the policy.
if ! security find-identity -p codesigning | grep -q "$IDENTITY"; then
    echo "No '$IDENTITY' signing identity; create it first (docs/signing.md, section 1)." >&2
    exit 1
fi

# Tags live on upstream, not origin, so a fresh clone has none until it fetches them.
if ! git describe --tags --abbrev=0 --match 'v[0-9]*.[0-9]*.[0-9]*' --exclude '*-*' >/dev/null 2>&1; then
    echo "Fetching upstream tags for the version number…"
    git fetch -q upstream --tags
fi
VERSION="$(git describe --tags --abbrev=0 --match 'v[0-9]*.[0-9]*.[0-9]*' --exclude '*-*' 2>/dev/null | sed 's/^v//')" || true
if [ -z "$VERSION" ]; then
    echo "No upstream stable tag reachable from HEAD; run 'git fetch upstream --tags' and retry." >&2
    exit 1
fi
BUILD_NUMBER="$(git rev-list --count HEAD)"

if [ -n "$(git status --porcelain --untracked-files=no)" ]; then
    echo "Warning: the working tree has uncommitted changes; this build will carry them." >&2
fi

# project.yml is the source of truth; a stale project would build without a newly added file.
xcodegen generate --quiet

echo "Building Tinycast $VERSION ($BUILD_NUMBER) from $(git rev-parse --short HEAD)"
xcodebuild -project Tinycast.xcodeproj -scheme Tinycast -configuration Release \
    -derivedDataPath build/dd -quiet \
    MARKETING_VERSION="$VERSION" CURRENT_PROJECT_VERSION="$BUILD_NUMBER" build
./Scripts/verify-signature.sh "$BUILT"

# Staged beside the target and verified before the old copy goes, so a failed copy installs nothing.
rm -rf "$STAGED"
ditto "$BUILT" "$STAGED"
codesign --verify --deep --strict "$STAGED"

osascript -e 'quit app id "com.tinycast.app"' 2>/dev/null || true
for _ in $(seq 40); do pgrep -f "$APP/Contents/MacOS/Tinycast" >/dev/null || break; sleep 0.5; done
if pgrep -f "$APP/Contents/MacOS/Tinycast" >/dev/null; then
    rm -rf "$STAGED"
    echo "Tinycast is still running after 20 s; quit it and retry." >&2
    exit 1
fi

rm -rf "$APP"
mv "$STAGED" "$APP"
open "$APP"
echo "✓ Installed Tinycast $VERSION ($BUILD_NUMBER)"
