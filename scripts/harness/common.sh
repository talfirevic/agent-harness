#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"

fail() {
  echo "ERROR: $*" >&2
  exit 1
}

info() {
  echo "[harness] $*"
}

to_root() {
  cd "$ROOT_DIR"
}

require_cmd() {
  local cmd="$1"
  command -v "$cmd" >/dev/null 2>&1 || fail "Required command not found: $cmd"
}

require_file() {
  local path="$1"
  [[ -f "$path" ]] || fail "Missing file: $path"
}

require_nonempty_file() {
  local path="$1"
  require_file "$path"
  [[ -s "$path" ]] || fail "Empty file: $path"
}

require_dir() {
  local path="$1"
  [[ -d "$path" ]] || fail "Missing directory: $path"
}

require_executable() {
  local path="$1"
  [[ -x "$path" ]] || fail "Missing executable script: $path"
}

require_contains() {
  local path="$1"
  local pattern="$2"
  if ! rg -q "$pattern" "$path"; then
    fail "Pattern '$pattern' not found in $path"
  fi
}

list_req_ids() {
  rg -o 'REQ-[0-9]{3}' REQUIREMENTS.md | sort -u
}

file_mtime_epoch() {
  local path="$1"
  if stat -f %m "$path" >/dev/null 2>&1; then
    stat -f %m "$path"
  else
    stat -c %Y "$path"
  fi
}

file_age_days() {
  local path="$1"
  local now
  local modified
  local age

  now="$(date +%s)"
  modified="$(file_mtime_epoch "$path")"
  age=$(( (now - modified) / 86400 ))
  if [[ "$age" -lt 0 ]]; then
    age=0
  fi
  printf '%s\n' "$age"
}
