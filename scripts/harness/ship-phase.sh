#!/usr/bin/env bash
set -euo pipefail

source "$(dirname "$0")/common.sh"
to_root

PHASE="1"
REQUEST="incremental delivery"
PARALLEL="auto"
DRY_RUN="true"
AUTO_MERGE="false"

usage() {
  cat <<'USAGE'
Usage: ./scripts/harness/ship-phase.sh [options]

Options:
  --phase N
  --request TEXT
  --parallel auto|off
  --dry-run true|false
  --auto-merge true|false
USAGE
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --phase) PHASE="$2"; shift 2 ;;
    --phase=*) PHASE="${1#*=}"; shift ;;
    --request) REQUEST="$2"; shift 2 ;;
    --request=*) REQUEST="${1#*=}"; shift ;;
    --parallel) PARALLEL="$2"; shift 2 ;;
    --parallel=*) PARALLEL="${1#*=}"; shift ;;
    --dry-run) DRY_RUN="$2"; shift 2 ;;
    --dry-run=*) DRY_RUN="${1#*=}"; shift ;;
    --auto-merge) AUTO_MERGE="$2"; shift 2 ;;
    --auto-merge=*) AUTO_MERGE="${1#*=}"; shift ;;
    -h|--help) usage; exit 0 ;;
    *) fail "Unknown argument: $1" ;;
  esac
done

case "$PARALLEL" in auto|off) ;; *) fail "--parallel must be auto|off" ;; esac
case "$DRY_RUN" in true|false) ;; *) fail "--dry-run must be true|false" ;; esac
case "$AUTO_MERGE" in true|false) ;; *) fail "--auto-merge must be true|false" ;; esac

./scripts/harness/verify-env.sh
./scripts/harness/change-classify.sh --request "$REQUEST"
./scripts/harness/research-gate.sh
./scripts/harness/phase-plan-gate.sh --phase "$PHASE"

plan_file=".planning/phases/phase-${PHASE}/PLAN.md"

if [[ "$PARALLEL" == "auto" ]]; then
  wave_numbers="$(rg -o '^## Wave [0-9]+' "$plan_file" | awk '{print $3}')"
  if [[ -z "$wave_numbers" ]]; then
    fail "No wave blocks found in $plan_file"
  fi

  while IFS= read -r wave; do
    [[ -n "$wave" ]] || continue
    ./scripts/harness/run-wave.sh --plan "$plan_file" --wave "$wave" --dry-run "$DRY_RUN" --auto-merge "$AUTO_MERGE"
  done <<EOF2
$wave_numbers
EOF2
fi

./scripts/harness/run-phase-verify.sh --phase "$PHASE"
./scripts/harness/phase-simplify.sh
./scripts/harness/update-knowledge-loop.sh

info "ship-phase completed"
