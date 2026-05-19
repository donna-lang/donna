#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DONNA="${DONNA:-"$ROOT/build/bin/donna"}"
case "$DONNA" in
  /*) ;;
  *) DONNA="$ROOT/$DONNA" ;;
esac
WORK="$(mktemp -d "${TMPDIR:-/tmp}/donna-smoke-XXXXXX")"

cleanup() {
  rm -rf "$WORK"
}
trap cleanup EXIT

cd "$WORK"
"$DONNA" new smoke

cd smoke
grep -q 'import donna/io' src/smoke.donna
grep -q 'io.println("Hello from smoke")' src/smoke.donna
if grep -q 'echo "Hello from smoke"' src/smoke.donna; then
  echo "fresh project should use io.println, not echo"
  cat src/smoke.donna
  exit 1
fi
"$DONNA" build
"$DONNA" run
"$DONNA" test
