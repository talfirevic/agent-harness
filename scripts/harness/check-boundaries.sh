#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$0")/common.sh"
to_root

require_nonempty_file docs/quality/INVARIANTS.md
require_nonempty_file docs/architecture/ARCHITECTURE.md

require_contains docs/quality/INVARIANTS.md 'Layer rule'
require_contains docs/architecture/ARCHITECTURE.md 'Boundary Rule'

info "check-boundaries passed"
