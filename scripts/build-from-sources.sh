#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SOURCES_DIR="${1:-${SOURCES_DIR:-"$ROOT/../sources"}}"
OUT_DIR="${OUT_DIR:-"$ROOT/build/bin"}"

fail() {
  printf '\033[31merror\033[0m: %s\n' "$1" >&2
}

host_target() {
  local os arch
  os="$(uname -s)"
  arch="$(uname -m)"

  case "$os:$arch" in
    Linux:x86_64) printf '%s:%s\n' "amd64_sysv" "donna" ;;
    Linux:aarch64|Linux:arm64) printf '%s:%s\n' "arm64" "donna" ;;
    Darwin:x86_64) printf '%s:%s\n' "amd64_apple" "donna" ;;
    Darwin:arm64) printf '%s:%s\n' "arm64_apple" "donna" ;;
    MINGW*:x86_64|MSYS*:x86_64|CYGWIN*:x86_64) printf '%s:%s\n' "amd64_win" "donna.exe" ;;
    *)
      fail "unsupported host: $os $arch"
      exit 1
      ;;
  esac
}

if [[ ! -d "$SOURCES_DIR" ]]; then
  fail "sources directory not found: $SOURCES_DIR"
  exit 1
fi

IFS=':' read -r target bin_name < <(host_target)
asm_dir="$SOURCES_DIR/targets/$target/asm"
ffi_dir="$SOURCES_DIR/ffi"

if [[ ! -d "$asm_dir" ]]; then
  fail "bootstrap assembly not found: $asm_dir"
  exit 1
fi

mkdir -p "$OUT_DIR"

asm_files=()
while IFS= read -r file; do
  asm_files+=("$file")
done < <(find "$asm_dir" -type f -name '*.s' | sort)

ffi_sources=()
if [[ -d "$ffi_dir" ]]; then
  while IFS= read -r file; do
    ffi_sources+=("$file")
  done < <(find "$ffi_dir" -type f -name '*.c' | sort)
fi

cc_cmd=()
if [[ -n "${CC:-}" ]]; then
  read -r -a cc_cmd <<< "$CC"
elif command -v cc >/dev/null 2>&1; then
  cc_cmd=(cc)
elif command -v zig >/dev/null 2>&1; then
  cc_cmd=(zig cc)
else
  fail "C compiler not found. Install cc/clang/gcc, install Zig, or set CC."
  exit 1
fi

cmd=("${cc_cmd[@]}")
cmd+=("${asm_files[@]}")
cmd+=("${ffi_sources[@]}")

case "$target" in
  amd64_apple|arm64_apple)
    cmd+=("-Wl,-stack_size,0x2000000")
    ;;
esac

cmd+=("-o" "$OUT_DIR/$bin_name")

printf '\033[38;5;208m  Bootstrap\033[0m %s -> %s\n' "$target" "$OUT_DIR/$bin_name"
"${cmd[@]}"
chmod +x "$OUT_DIR/$bin_name"
