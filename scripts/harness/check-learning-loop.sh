#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$0")/common.sh"
to_root

require_nonempty_file .claude/skills/project-update-knowledge/SKILL.md
require_nonempty_file docs/quality/SCORECARD.md
require_nonempty_file docs/quality/FLAKE_POLICY.md
require_nonempty_file .github/workflows/doc-gardener.yml
require_nonempty_file scripts/harness/knowledge-contract.sh

require_contains .github/workflows/doc-gardener.yml 'docs-lint.sh'
require_contains .github/workflows/doc-gardener.yml 'check-artifact-sync.sh'
require_contains .github/workflows/doc-gardener.yml 'knowledge-contract.sh'

info "check-learning-loop passed"
