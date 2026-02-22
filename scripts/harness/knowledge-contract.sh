#!/usr/bin/env bash
set -euo pipefail

source "$(dirname "$0")/common.sh"
to_root

require_nonempty_file docs/_meta/KNOWLEDGE_MAP.yml
require_nonempty_file AGENTS.md

agents_lines="$(wc -l < AGENTS.md | tr -d ' ')"
if [[ "$agents_lines" -gt 220 ]]; then
  fail "AGENTS.md must stay short (<=220 lines). Current: $agents_lines"
fi

current_path=""
current_freshness=""

check_doc_freshness() {
  local path="$1"
  local freshness="$2"

  [[ -n "$path" ]] || return 0
  [[ -n "$freshness" ]] || fail "Missing freshness_days for $path"

  require_nonempty_file "$path"
  age_days="$(file_age_days "$path")"
  if [[ "$age_days" -gt "$freshness" ]]; then
    fail "Freshness violation: $path is $age_days days old (limit $freshness)"
  fi
}

while IFS= read -r line; do
  case "$line" in
    *"- path:"*)
      if [[ -n "$current_path" ]]; then
        check_doc_freshness "$current_path" "$current_freshness"
      fi
      current_path="$(printf '%s' "$line" | sed -E 's/.*- path:[[:space:]]*//; s/"//g')"
      current_freshness=""
      ;;
    *"freshness_days:"*)
      current_freshness="$(printf '%s' "$line" | sed -E 's/.*freshness_days:[[:space:]]*//')"
      ;;
  esac
done < docs/_meta/KNOWLEDGE_MAP.yml

if [[ -n "$current_path" ]]; then
  check_doc_freshness "$current_path" "$current_freshness"
fi

mapfile_fallback_reqs() {
  while IFS= read -r req; do
    [[ -n "$req" ]] && printf '%s\n' "$req"
  done < <(list_req_ids)
}

found_req="false"
while IFS= read -r req; do
  found_req="true"
  rg -q "$req" .planning/phases/*/PLAN.md || fail "REQ missing from PLAN artifacts: $req"
  rg -q "$req" .planning/phases/*/VERIFICATION.md || fail "REQ missing from VERIFICATION artifacts: $req"
done < <(mapfile_fallback_reqs)

[[ "$found_req" == "true" ]] || fail "No REQ IDs found in REQUIREMENTS.md"

while IFS= read -r gap; do
  [[ -n "$gap" ]] || continue
  gap_file=".planning/gaps/$gap.md"
  require_nonempty_file "$gap_file"
  rg -q "$gap" .planning/STATE.md || fail "Gap missing from STATE: $gap"
done < <(rg -o 'GAP-[0-9]{3}' .planning/STATE.md | sort -u)

info "knowledge-contract passed"
