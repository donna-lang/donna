#!/usr/bin/env bash
set -u

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
OUT_DIR="${OUT_DIR:-"$ROOT/build/cross"}"
DONNA_BIN="${DONNA_BIN:-"$ROOT/build/bin/donna"}"

QBE_TARGETS=(
  "amd64_sysv:x86_64-linux-gnu:donna"
  "amd64_apple:x86_64-macos:donna"
  "amd64_win:x86_64-windows-gnu:donna.exe"
  "arm64:aarch64-linux-gnu:donna"
  "arm64_apple:aarch64-macos:donna"
)

PACKAGES=(donna argparse parsetoml markdown json)

log() {
  printf '\033[38;5;208m  %s\033[0m %s\n' "$1" "${2:-}"
}

fail() {
  printf '\033[31merror\033[0m: %s\n' "$1" >&2
}

need_cmd() {
  if ! command -v "$1" >/dev/null 2>&1; then
    fail "missing required command: $1"
    exit 1
  fi
}

quote_args() {
  local out=()
  local arg
  for arg in "$@"; do
    out+=("$(printf '%q' "$arg")")
  done
  printf '%s ' "${out[@]}"
}

collect_ssa_files() {
  find "$ROOT/build/dev/artifacts" -type f -name '*.ssa' | sort

  local pkg
  for pkg in "${PACKAGES[@]}"; do
    local dir="$ROOT/build/packages/$pkg/artifacts"
    if [[ -d "$dir" ]]; then
      find "$dir" -type f -name '*.ssa' | sort
    fi
  done
}

collect_ffi_sources() {
  local pkg
  for pkg in "${PACKAGES[@]}"; do
    local dir="$HOME/.donna/packages/$pkg/ffi"
    if [[ -d "$dir" ]]; then
      find "$dir" -type f -name '*.c' | sort
    fi
  done
}

target_link_flags() {
  local qbe_target="$1"
  case "$qbe_target" in
    amd64_apple|arm64_apple)
      printf '%s\n' "-Wl,-stack_size,0x2000000"
      ;;
  esac
}

build_target() {
  local qbe_target="$1"
  local zig_target="$2"
  local bin_name="$3"
  local target_dir="$OUT_DIR/$qbe_target"
  local asm_dir="$target_dir/asm"
  local bin_path="$target_dir/$bin_name"
  local qbe_log="$target_dir/qbe.log"
  local zig_log="$target_dir/zig-cc.log"

  rm -rf "$target_dir"
  mkdir -p "$asm_dir"
  : > "$qbe_log"
  : > "$zig_log"

  log "Target" "$qbe_target -> $zig_target"

  local asm_files=()
  local ssa
  while IFS= read -r ssa; do
    local rel="${ssa#$ROOT/build/}"
    local stem="${rel%.ssa}"
    stem="${stem//\//_}"
    local asm="$asm_dir/$stem.s"
    if ! qbe -t "$qbe_target" -o "$asm" "$ssa" >>"$qbe_log" 2>&1; then
      fail "qbe failed for $qbe_target; see $qbe_log"
      return 1
    fi
    asm_files+=("$asm")
  done < <(collect_ssa_files)

  local ffi_sources=()
  local ffi_dir="$target_dir/ffi"
  mkdir -p "$ffi_dir"
  local ffi
  while IFS= read -r ffi; do
    ffi_sources+=("$ffi")
  done < <(collect_ffi_sources)

  local link_flags=()
  local flag
  while IFS= read -r flag; do
    [[ -n "$flag" ]] && link_flags+=("$flag")
  done < <(target_link_flags "$qbe_target")

  local cmd=(zig cc -target "$zig_target" -O2)
  cmd+=("${asm_files[@]}")
  cmd+=("${ffi_sources[@]}")
  if [[ "${#link_flags[@]}" -gt 0 ]]; then
    cmd+=("${link_flags[@]}")
  fi
  cmd+=(-o "$bin_path")

  printf 'zig cc command:\n%s\n' "$(quote_args "${cmd[@]}")" > "$zig_log"
  if ! "${cmd[@]}" >>"$zig_log" 2>&1; then
    fail "zig cc failed for $qbe_target; see $zig_log"
    return 1
  fi

  log "Built" "$bin_path"
  return 0
}

main() {
  need_cmd qbe
  need_cmd zig
  ulimit -s 32768 2>/dev/null || true

  if [[ ! -x "$DONNA_BIN" ]]; then
    fail "compiler binary not found: $DONNA_BIN"
    fail "run donna build first, or set DONNA_BIN=/path/to/donna"
    exit 1
  fi

  log "Refreshing" "compiler SSA with $DONNA_BIN"
  if ! "$DONNA_BIN" build >/dev/null; then
    fail "failed to build compiler SSA artifacts"
    exit 1
  fi

  rm -rf "$OUT_DIR"
  mkdir -p "$OUT_DIR"

  local failures=0
  local spec
  for spec in "${QBE_TARGETS[@]}"; do
    IFS=':' read -r qbe_target zig_target bin_name <<< "$spec"
    if ! build_target "$qbe_target" "$zig_target" "$bin_name"; then
      failures=$((failures + 1))
    fi
  done

  if [[ "$failures" -ne 0 ]]; then
    fail "$failures target(s) failed"
    exit 1
  fi

  log "Done" "$OUT_DIR"
}

main "$@"
