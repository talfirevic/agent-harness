#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$0")/common.sh"
to_root

require_nonempty_file REQUIREMENTS.md
require_nonempty_file tests/TRACEABILITY.md
require_nonempty_file .planning/phases/phase-1/VERIFICATION.md

reqs=()
while IFS= read -r req; do
  [[ -n "$req" ]] && reqs+=("$req")
done < <(list_req_ids)

[[ "${#reqs[@]}" -gt 0 ]] || fail "No REQ IDs found"

for req in "${reqs[@]}"; do
  rg -q "$req" tests/TRACEABILITY.md || fail "REQ missing from tests traceability: $req"
  rg -q "$req" .planning/phases/phase-1/VERIFICATION.md || fail "REQ missing from verification artifact: $req"
done

info "check-req-coverage passed"
