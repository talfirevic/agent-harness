#!/usr/bin/env bash
set -euo pipefail

source "$(dirname "$0")/common.sh"
to_root

require_nonempty_file docs/quality/SCORECARD.md
require_nonempty_file docs/quality/FLAKE_POLICY.md

cat >> docs/quality/SCORECARD.md <<EOF2

Update $(date +%F): verification loop executed by ship-phase.
EOF2

info "update-knowledge-loop completed"
