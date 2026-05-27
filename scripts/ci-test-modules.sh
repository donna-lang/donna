#!/usr/bin/env sh
set -eu

DONNA_BIN="${DONNA:-build/bin/donna}"

for file in test/*.donna; do
  module="$(basename "$file" .donna)"
  "$DONNA_BIN" test --only "$module"
done
