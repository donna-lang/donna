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
"$DONNA" build
"$DONNA" run
"$DONNA" test

printf 'pub fn main() -> Nil:\n  let broken =\n' > src/smoke.donna
if "$DONNA" build >/tmp/donna-smoke-bad-build.log 2>&1; then
  echo "expected bad fresh project build to fail"
  cat /tmp/donna-smoke-bad-build.log
  exit 1
fi
