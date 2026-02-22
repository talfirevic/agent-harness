#!/usr/bin/env bash
set -euo pipefail

source "$(dirname "$0")/common.sh"
to_root

REQUEST=""
OUTPUT=".planning/LANE.md"

usage() {
  cat <<'USAGE'
Usage: ./scripts/harness/change-classify.sh --request "text" [--output .planning/LANE.md]
USAGE
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --request) REQUEST="$2"; shift 2 ;;
    --request=*) REQUEST="${1#*=}"; shift ;;
    --output) OUTPUT="$2"; shift 2 ;;
    --output=*) OUTPUT="${1#*=}"; shift ;;
    -h|--help) usage; exit 0 ;;
    *) fail "Unknown argument: $1" ;;
  esac
done

[[ -n "$REQUEST" ]] || REQUEST="default incremental change"

lane="incremental"
if printf '%s' "$REQUEST" | rg -qi 'bug|fix|regression'; then
  lane="bugfix"
fi
if printf '%s' "$REQUEST" | rg -qi 'pivot|rewrite|redo|re-arch'; then
  lane="pivot"
fi

cat > "$OUTPUT" <<LANE
lane: $lane
request: "$REQUEST"
updated: "$(date +%F)"
LANE

info "change classified as $lane"
