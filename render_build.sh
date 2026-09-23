#!/usr/bin/env bash
set -euo pipefail

# Render's native image does not include Flutter. Install the same stable SDK
# used by the project instead of relying on Render's runtime detection.
FLUTTER_VERSION="3.44.9"
SDK_ARCHIVE_SHA256="a9120fa4a01048bdef438ddc3a2d4b7389662ea98a95db86eeaf10382bc4efcb"
SDK_ROOT="${RENDER_TMP_ROOT:-/tmp}/flutter-${FLUTTER_VERSION}"
SDK_ARCHIVE="${SDK_ROOT}.tar.xz"
SDK_URL="https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_${FLUTTER_VERSION}-stable.tar.xz"

if [[ ! -x "${SDK_ROOT}/bin/flutter" ]]; then
  rm -rf "$SDK_ROOT" "$SDK_ARCHIVE"
  mkdir -p "$(dirname "$SDK_ROOT")"

  echo "Downloading Flutter ${FLUTTER_VERSION}…"
  curl --fail --location --retry 3 --retry-delay 2 \
    "$SDK_URL" \
    --output "$SDK_ARCHIVE"

  echo "${SDK_ARCHIVE_SHA256}  ${SDK_ARCHIVE}" | sha256sum --check --status
  mkdir -p "$SDK_ROOT"
  tar -xJf "$SDK_ARCHIVE" -C "$SDK_ROOT" --strip-components=1
  rm -f "$SDK_ARCHIVE"
fi

export PATH="${SDK_ROOT}/bin:${PATH}"
flutter config --no-analytics >/dev/null
flutter pub get
flutter build web --release
