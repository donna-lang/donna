#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
VERSION="${GITHUB_REF_NAME:-dev}"
VERSION="${VERSION#v}"
DIST="$ROOT/dist"

rm -rf "$DIST"
mkdir -p "$DIST"

"$ROOT/scripts/build-targets.sh"

package_unix() {
  local target="$1"
  local platform="$2"
  local arch="$3"
  local bin="$ROOT/build/cross/$target/donna"
  local stage="$DIST/donna-$VERSION-$platform-$arch"

  mkdir -p "$stage/bin"
  cp "$bin" "$stage/bin/donna"
  cp "$ROOT/README.md" "$stage/README.md"
  tar -C "$DIST" -czf "$stage.tar.gz" "$(basename "$stage")"
  rm -rf "$stage"
}

package_windows() {
  local stage="$DIST/donna-$VERSION-windows-x86_64"

  mkdir -p "$stage/bin"
  cp "$ROOT/build/cross/amd64_win/donna.exe" "$stage/bin/donna.exe"
  cp "$ROOT/README.md" "$stage/README.md"
  (cd "$DIST" && zip -qr "$(basename "$stage").zip" "$(basename "$stage")")
  rm -rf "$stage"
}

package_unix amd64_sysv linux x86_64
package_unix arm64 linux aarch64
package_unix amd64_apple macos x86_64
package_unix arm64_apple macos aarch64
package_windows

find "$DIST" -type f | sort

