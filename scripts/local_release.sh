#!/usr/bin/env bash
# Local replacement for the CodeMagic release scripts.
# Usage:
#   cp .env.example .env   # then fill values
#   ./scripts/local_release.sh android
#   ./scripts/local_release.sh ios
#   ./scripts/local_release.sh both
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

if [[ ! -f .env ]]; then
  echo "Missing .env. Copy .env.example to .env and fill the CodeMagic values."
  exit 1
fi

set -a
# shellcheck disable=SC1091
source .env
set +a

TARGET="${1:-android}"
BUILD_NAME="${BUILD_NAME:-1.0.0}"
BUILD_NUMBER="${BUILD_NUMBER:-1}"

if [[ -z "${RC_ANDROID_PUBLIC_KEY:-}" || -z "${RC_IOS_PUBLIC_KEY:-}" ]]; then
  echo "RC_ANDROID_PUBLIC_KEY and RC_IOS_PUBLIC_KEY must be set in .env"
  exit 1
fi

# Only public SDK keys go into the binary. Signing secrets stay out of dart-define.
DEFINES="$(mktemp)"
trap 'rm -f "$DEFINES"' EXIT
printf 'RC_ANDROID_PUBLIC_KEY=%s\nRC_IOS_PUBLIC_KEY=%s\n' \
  "$RC_ANDROID_PUBLIC_KEY" \
  "$RC_IOS_PUBLIC_KEY" > "$DEFINES"

prepare_android_signing() {
  if [[ -n "${CM_KEYSTORE:-}" ]]; then
    echo "$CM_KEYSTORE" | base64 --decode > android/keystore.jks
  fi
  if [[ ! -f android/keystore.jks ]]; then
    echo "android/keystore.jks is missing. Add the file or set CM_KEYSTORE (base64) in .env"
    exit 1
  fi
  if [[ -z "${CM_KEYSTORE_PASSWORD:-}" || -z "${CM_KEY_PASSWORD:-}" || -z "${CM_KEY_ALIAS:-}" ]]; then
    echo "Set CM_KEYSTORE_PASSWORD, CM_KEY_PASSWORD, and CM_KEY_ALIAS in .env"
    exit 1
  fi
  cat > android/key.properties <<EOF
storePassword=$CM_KEYSTORE_PASSWORD
keyPassword=$CM_KEY_PASSWORD
keyAlias=$CM_KEY_ALIAS
storeFile=../keystore.jks
EOF
}

build_android() {
  prepare_android_signing
  flutter build appbundle --release \
    --build-name="$BUILD_NAME" \
    --build-number="$BUILD_NUMBER" \
    --dart-define-from-file="$DEFINES"
  echo "AAB: build/app/outputs/bundle/release/app-release.aab"
}

build_ios() {
  flutter build ipa --release \
    --build-name="$BUILD_NAME" \
    --build-number="$BUILD_NUMBER" \
    --dart-define-from-file="$DEFINES"
  echo "IPA: build/ios/ipa/"
}

case "$TARGET" in
  android) build_android ;;
  ios) build_ios ;;
  both)
    build_android
    build_ios
    ;;
  *)
    echo "Usage: $0 android|ios|both"
    exit 1
    ;;
esac
