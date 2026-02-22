#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
INCLUDE_FILE="$REPO_ROOT/bundle/include-paths.txt"

usage() {
  cat <<'EOF'
Usage:
  ./scripts/release/build-bundle.sh --version <version> [--output-dir <path>]

Builds release artifacts:
- harness-bundle.tar.gz
- sha256sums.txt
- VERSION
- MANIFEST.txt
EOF
}

info() {
  echo "[build-bundle] $*"
}

fail() {
  echo "ERROR: $*" >&2
  exit 1
}

require_cmd() {
  local cmd="$1"
  command -v "$cmd" >/dev/null 2>&1 || fail "Required command not found: $cmd"
}

sha256_file() {
  local file="$1"
  if command -v sha256sum >/dev/null 2>&1; then
    sha256sum "$file" | awk '{print $1}'
    return
  fi

  if command -v shasum >/dev/null 2>&1; then
    shasum -a 256 "$file" | awk '{print $1}'
    return
  fi

  fail "No SHA-256 tool found (need sha256sum or shasum)"
}

validate_include_entry() {
  local entry="$1"
  local segment

  [[ "$entry" != /* ]] || fail "Include entry must be relative: $entry"

  IFS='/' read -r -a segments <<< "$entry"
  for segment in "${segments[@]}"; do
    if [[ -z "$segment" || "$segment" == "." || "$segment" == ".." ]]; then
      fail "Unsafe include entry: $entry"
    fi
  done
}

VERSION=""
OUTPUT_DIR="$REPO_ROOT/dist/release"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --version)
      [[ $# -ge 2 ]] || fail "Missing value for --version"
      VERSION="$2"
      shift 2
      ;;
    --version=*)
      VERSION="${1#*=}"
      shift
      ;;
    --output-dir)
      [[ $# -ge 2 ]] || fail "Missing value for --output-dir"
      OUTPUT_DIR="$2"
      shift 2
      ;;
    --output-dir=*)
      OUTPUT_DIR="${1#*=}"
      shift
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      fail "Unknown argument: $1"
      ;;
  esac
done

[[ -n "$VERSION" ]] || fail "--version is required"
[[ -f "$INCLUDE_FILE" ]] || fail "Missing include list: $INCLUDE_FILE"

require_cmd awk
require_cmd find
require_cmd sort
require_cmd tar
require_cmd tr

mkdir -p "$OUTPUT_DIR"

tmp_dir="$(mktemp -d)"
trap 'rm -rf "$tmp_dir"' EXIT

manifest_tmp="$tmp_dir/MANIFEST.txt"
: > "$manifest_tmp"

while IFS= read -r raw || [[ -n "$raw" ]]; do
  entry="${raw%$'\r'}"
  [[ -n "$entry" ]] || continue
  [[ "$entry" != \#* ]] || continue

  validate_include_entry "$entry"

  source_path="$REPO_ROOT/$entry"
  [[ -e "$source_path" ]] || fail "Include path not found: $entry"

  if [[ -d "$source_path" ]]; then
    (cd "$REPO_ROOT" && find "$entry" -type f | sort) >> "$manifest_tmp"
  else
    printf '%s\n' "$entry" >> "$manifest_tmp"
  fi
done < "$INCLUDE_FILE"

sort -u "$manifest_tmp" > "$OUTPUT_DIR/MANIFEST.txt"

printf '%s\n' "$VERSION" > "$OUTPUT_DIR/VERSION"

tar -czf "$OUTPUT_DIR/harness-bundle.tar.gz" -C "$REPO_ROOT" -T "$OUTPUT_DIR/MANIFEST.txt"

{
  for artifact in harness-bundle.tar.gz MANIFEST.txt VERSION; do
    checksum="$(sha256_file "$OUTPUT_DIR/$artifact")"
    printf '%s  %s\n' "$checksum" "$artifact"
  done
} > "$OUTPUT_DIR/sha256sums.txt"

info "Built release artifacts in $OUTPUT_DIR"
info "VERSION=$VERSION"
