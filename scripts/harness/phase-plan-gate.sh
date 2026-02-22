#!/usr/bin/env bash
set -euo pipefail

source "$(dirname "$0")/common.sh"
to_root

PHASE="1"
PLAN_PATH=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --phase) PHASE="$2"; shift 2 ;;
    --phase=*) PHASE="${1#*=}"; shift ;;
    --plan) PLAN_PATH="$2"; shift 2 ;;
    --plan=*) PLAN_PATH="${1#*=}"; shift ;;
    *) fail "Unknown argument: $1" ;;
  esac
done

[[ -n "$PLAN_PATH" ]] || PLAN_PATH=".planning/phases/phase-${PHASE}/PLAN.md"

require_nonempty_file "$PLAN_PATH"
require_contains "$PLAN_PATH" 'touches:'
require_contains "$PLAN_PATH" 'reqs:'
require_contains "$PLAN_PATH" 'verification:'

info "phase-plan-gate passed for phase $PHASE"
