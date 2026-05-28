#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
OUT="${1:-${BOOTSTRAP_OUT:-"$ROOT/../sources"}}"

"$ROOT/scripts/build-targets.sh"

rm -rf "$OUT/targets" "$OUT/ffi" "$OUT/checksums.sha256"
mkdir -p "$OUT/targets" "$OUT/ffi"

for target in amd64_sysv amd64_apple amd64_win arm64 arm64_apple; do
  mkdir -p "$OUT/targets/$target/asm"
  rsync -a "$ROOT/build/cross/$target/asm/" "$OUT/targets/$target/asm/"
done

for pkg in donna argparse markdown json; do
  if [[ -d "$HOME/.donna/packages/$pkg/ffi" ]]; then
    mkdir -p "$OUT/ffi/$pkg"
    rsync -a "$HOME/.donna/packages/$pkg/ffi/" "$OUT/ffi/$pkg/"
  fi
done

(
  cd "$OUT"
  find targets ffi -type f | sort | xargs shasum -a 256 > checksums.sha256
)
