#!/usr/bin/env bash
set -euo pipefail

source "$(dirname "$0")/common.sh"
to_root

PHASE="1"
while [[ $# -gt 0 ]]; do
  case "$1" in
    --phase) PHASE="$2"; shift 2 ;;
    --phase=*) PHASE="${1#*=}"; shift ;;
    *) fail "Unknown argument: $1" ;;
  esac
done

./scripts/harness/check-req-coverage.sh
./scripts/harness/check-all.sh

verification_file=".planning/phases/phase-${PHASE}/VERIFICATION.md"
require_nonempty_file "$verification_file"

info "phase verification passed for phase $PHASE"
