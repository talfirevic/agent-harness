#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$0")/common.sh"
to_root

require_nonempty_file .planning/ROADMAP.md
require_nonempty_file .planning/STATE.md
require_nonempty_file .planning/phases/phase-1/PLAN.md

require_contains .planning/STATE.md 'current_milestone'
require_contains .planning/STATE.md 'current_phase'
require_contains .planning/phases/phase-1/PLAN.md 'touches:'
require_contains .planning/phases/phase-1/PLAN.md 'reqs:'
require_contains .planning/phases/phase-1/PLAN.md 'verification:'

info "check-plan-contract passed"
