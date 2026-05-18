#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
VERSION="${GITHUB_REF_NAME:-dev}"
VERSION="${VERSION#v}"
DIST="$ROOT/dist"
DONNA_BIN="${DONNA_BIN:-"$ROOT/build/bin/donna"}"
RELEASE_ROOT="$ROOT/build/release/target"

rm -rf "$DIST"
mkdir -p "$DIST"

if [[ ! -x "$DONNA_BIN" ]]; then
  printf '\033[31merror\033[0m: compiler binary not found: %s\n' "$DONNA_BIN" >&2
  printf '\033[2m  run make build first, or set DONNA_BIN=/path/to/donna\033[0m\n' >&2
  exit 1
fi

ulimit -s unlimited 2>/dev/null || ulimit -s 32768 2>/dev/null || true
"$DONNA_BIN" build --release --target=all

package_unix() {
  local target="$1"
  local platform="$2"
  local arch="$3"
  local bin="$RELEASE_ROOT/$target/bin/donna"
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
  cp "$RELEASE_ROOT/amd64_win/bin/donna.exe" "$stage/bin/donna.exe"
  cp "$ROOT/README.md" "$stage/README.md"
  (cd "$DIST" && zip -qr "$(basename "$stage").zip" "$(basename "$stage")")
  rm -rf "$stage"
}

package_unix amd64 linux x86_64
package_unix arm64 linux aarch64
package_unix amd64_apple macos x86_64
package_unix arm64_apple macos aarch64
package_windows

find "$DIST" -type f | sort
