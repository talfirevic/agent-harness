#!/usr/bin/env bash
set -euo pipefail

source "$(dirname "$0")/common.sh"
to_root

mkdir -p \
  .claude/hooks \
  .claude/agents \
  .claude/skills \
  .planning/phases \
  .planning/tasks \
  .planning/locks \
  .planning/gaps \
  .github/workflows \
  docs/_meta \
  docs/architecture \
  docs/design \
  docs/quality \
  docs/ops \
  docs/runbooks \
  scripts/harness \
  tests/structural \
  tests/unit \
  src

seed_if_missing() {
  local path="$1"
  local content="$2"
  if [[ ! -f "$path" ]]; then
    mkdir -p "$(dirname "$path")"
    printf '%s' "$content" > "$path"
  fi
}

seed_if_missing .planning/locks/LOCKS.json '{
  "locks": []
}
'

seed_if_missing .planning/gaps/GAP-001.md '# GAP-001

Status: open
Owner: engineering
Reason: initial scaffold gap placeholder
Linked from: .planning/STATE.md
'

seed_if_missing docs/_meta/KNOWLEDGE_MAP.yml 'required_docs:
  - path: AGENTS.md
    owner: engineering
    freshness_days: 30
  - path: PROJECT.md
    owner: product
    freshness_days: 14
  - path: REQUIREMENTS.md
    owner: product
    freshness_days: 14
  - path: docs/architecture/ARCHITECTURE.md
    owner: engineering
    freshness_days: 30
  - path: docs/design/STYLE_GUIDE.md
    owner: design
    freshness_days: 30
  - path: docs/quality/INVARIANTS.md
    owner: engineering
    freshness_days: 30
  - path: .planning/STATE.md
    owner: engineering
    freshness_days: 7
link_contracts:
  req_to_plan_glob: .planning/phases/**/PLAN.md
  req_to_verify_glob: .planning/phases/**/VERIFICATION.md
  state_to_gap_glob: .planning/gaps/GAP-*.md
'

info "scaffold-harness completed"
