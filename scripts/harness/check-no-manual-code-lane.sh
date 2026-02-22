#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$0")/common.sh"
to_root

require_nonempty_file AGENTS.md
require_nonempty_file .claude/skills/autonomous-build/SKILL.md
require_nonempty_file HARNESS_PRINCIPLES.md

require_contains AGENTS.md 'Humans do not manually write product code'
require_contains .claude/skills/autonomous-build/SKILL.md 'Manual code writing is prohibited'
require_contains HARNESS_PRINCIPLES.md 'HP-001'

info "check-no-manual-code-lane passed"
