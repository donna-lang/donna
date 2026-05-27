#!/usr/bin/env sh
set -eu

DONNA_BIN="${DONNA:-build/bin/donna}"

for file in test/*.donna; do
  module="$(basename "$file" .donna)"
  case "$module" in
    dependencies_test) continue ;;
  esac
  rm -f build/test/donna_test_runner \
    build/test/test_runner.donna \
    build/test/test_runner.iface \
    build/test/test_runner.s \
    build/test/test_runner.ssa
  "$DONNA_BIN" test --only "$module"
done
