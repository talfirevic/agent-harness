#!/usr/bin/env bash
set -euo pipefail

source "$(dirname "$0")/common.sh"
to_root

require_nonempty_file .planning/RESEARCH.md

today="$(date +%F)"
if ! rg -q "As of ${today}" .planning/RESEARCH.md; then
  cat > .planning/RESEARCH.md <<RESEARCH
# RESEARCH

As of ${today}:
- Refresh stack docs and release notes before planning.
- Track deprecations and security advisories for selected dependencies.
- Link references used for implementation decisions.
RESEARCH
fi

info "research-gate passed"
