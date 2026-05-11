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

printf 'pub fn main() -> Nil:\n  let route = string.to_slug("Language Tour")\n  echo route\n' > src/smoke.donna
if "$DONNA" build >/tmp/donna-smoke-bad-build.log 2>&1; then
  echo "expected bad fresh project build to fail"
  cat /tmp/donna-smoke-bad-build.log
  exit 1
fi
grep -q "undefined module" /tmp/donna-smoke-bad-build.log
grep -q "\`string\` has not been imported" /tmp/donna-smoke-bad-build.log
if grep -q "type error in" /tmp/donna-smoke-bad-build.log; then
  echo "unexpected redundant type error wrapper"
  cat /tmp/donna-smoke-bad-build.log
  exit 1
fi
