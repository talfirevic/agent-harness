#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$0")/common.sh"
to_root

require_nonempty_file PROJECT.md
require_nonempty_file REQUIREMENTS.md
require_nonempty_file .planning/ROADMAP.md
require_nonempty_file .planning/STATE.md

reqs=()
while IFS= read -r req; do
  [[ -n "$req" ]] && reqs+=("$req")
done < <(list_req_ids)

[[ "${#reqs[@]}" -gt 0 ]] || fail "No REQ IDs found in REQUIREMENTS.md"

for req in "${reqs[@]}"; do
  if ! rg -q "$req" .planning/ROADMAP.md .planning/STATE.md .planning/phases tests/TRACEABILITY.md; then
    fail "REQ not synchronized across artifacts: $req"
  fi
done

while IFS= read -r gap; do
  [[ -n "$gap" ]] || continue
  gap_file=".planning/gaps/$gap.md"
  require_nonempty_file "$gap_file"
  rg -q "$gap" .planning/phases .planning/STATE.md || fail "GAP not cross-linked to planning artifacts: $gap"
done < <(rg -o 'GAP-[0-9]{3}' .planning/STATE.md | sort -u)

info "check-artifact-sync passed"
