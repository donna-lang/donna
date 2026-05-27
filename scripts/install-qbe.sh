#!/usr/bin/env bash
set -euo pipefail

PREFIX="${1:-/usr/local}"
WORK="${RUNNER_TEMP:-/tmp}/donna-qbe"

if command -v qbe >/dev/null 2>&1; then
  qbe --version 2>/dev/null || true
  exit 0
fi


rm -rf "$WORK"
git clone git://c9x.me/qbe.git "$WORK"
make -C "$WORK"
sudo make -C "$WORK" PREFIX="$PREFIX" install
