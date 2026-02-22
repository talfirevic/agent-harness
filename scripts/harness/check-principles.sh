#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$0")/common.sh"
to_root

require_nonempty_file HARNESS_PRINCIPLES.md

for id in HP-001 HP-002 HP-003 HP-004 HP-005 HP-006 HP-007 HP-008; do
  require_contains HARNESS_PRINCIPLES.md "$id"
done

checks=(
  check-no-manual-code-lane.sh
  check-artifact-sync.sh
  check-legibility.sh
  check-boundaries.sh
  check-structural-tests.sh
  check-taste-invariants.sh
  check-plan-contract.sh
  check-lock-protocol.sh
  check-parallel-orchestration.sh
  check-req-coverage.sh
  check-toolchain-baseline.sh
  knowledge-contract.sh
  check-learning-loop.sh
)

for check in "${checks[@]}"; do
  require_executable "scripts/harness/$check"
  ./scripts/harness/"$check"
done

info "check-principles passed"
