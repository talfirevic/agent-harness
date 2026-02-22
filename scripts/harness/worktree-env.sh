#!/usr/bin/env bash
set -euo pipefail

source "$(dirname "$0")/common.sh"
to_root

WORKTREE_ID=""
FORMAT="export"

usage() {
  cat <<'USAGE'
Usage: ./scripts/harness/worktree-env.sh --worktree-id my-id [--format export|env|json]
USAGE
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --worktree-id)
      WORKTREE_ID="$2"
      shift 2
      ;;
    --worktree-id=*)
      WORKTREE_ID="${1#*=}"
      shift
      ;;
    --format)
      FORMAT="$2"
      shift 2
      ;;
    --format=*)
      FORMAT="${1#*=}"
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

[[ -n "$WORKTREE_ID" ]] || fail "--worktree-id is required"

safe_id="$(printf '%s' "$WORKTREE_ID" | tr '[:upper:]' '[:lower:]' | sed -E 's/[^a-z0-9]+/_/g; s/^_+//; s/_+$//')"
[[ -n "$safe_id" ]] || safe_id="worktree"

hash="$(printf '%s' "$WORKTREE_ID" | cksum | awk '{print $1}')"
port_base=$((4100 + (hash % 700)))

db_schema="app_${safe_id}"
tmp_dir=".tmp/${safe_id}"

case "$FORMAT" in
  export)
    cat <<ENV
export WORKTREE_ID="$safe_id"
export PORT_BASE="$port_base"
export DB_SCHEMA="$db_schema"
export TMP_DIR="$tmp_dir"
ENV
    ;;
  env)
    cat <<ENV
WORKTREE_ID=$safe_id
PORT_BASE=$port_base
DB_SCHEMA=$db_schema
TMP_DIR=$tmp_dir
ENV
    ;;
  json)
    cat <<JSON
{"WORKTREE_ID":"$safe_id","PORT_BASE":$port_base,"DB_SCHEMA":"$db_schema","TMP_DIR":"$tmp_dir"}
JSON
    ;;
  *)
    fail "--format must be export|env|json"
    ;;
esac
