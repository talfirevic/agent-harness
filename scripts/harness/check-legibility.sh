#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$0")/common.sh"
to_root

require_nonempty_file docs/ops/LEGIBILITY.md
require_executable scripts/dev-up.sh
require_executable scripts/test-all.sh
require_executable scripts/harness/worktree-env.sh
require_executable scripts/harness/worktree-create.sh

require_contains docs/ops/LEGIBILITY.md 'Worktree'
require_contains docs/ops/LEGIBILITY.md 'PORT_BASE'
require_contains docs/ops/LEGIBILITY.md 'structured logs'

./scripts/dev-up.sh --check >/dev/null
./scripts/test-all.sh --check >/dev/null

info "check-legibility passed"
