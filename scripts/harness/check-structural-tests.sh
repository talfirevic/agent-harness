#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$0")/common.sh"
to_root

require_nonempty_file tests/structural/README.md
require_nonempty_file .planning/phases/phase-1/PLAN.md

info "check-structural-tests passed"
