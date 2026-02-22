#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$0")/common.sh"
to_root

require_nonempty_file .planning/locks/LOCKS.json
require_nonempty_file .claude/agents/executor.md
require_nonempty_file .claude/skills/resolve-overlap/SKILL.md
require_nonempty_file .planning/phases/phase-1/PLAN.md
require_executable scripts/harness/lock-manager.sh

require_contains .planning/locks/LOCKS.json '"locks"'
require_contains .claude/agents/executor.md 'Acquire lock'
require_contains .planning/phases/phase-1/PLAN.md 'touches:'

./scripts/harness/lock-manager.sh acquire --task-id LOCKTEST --owner check-lock --branch check-lock --touches .planning/STATE.md >/dev/null
if ./scripts/harness/lock-manager.sh acquire --task-id LOCKTEST2 --owner check-lock --branch check-lock-2 --touches .planning/STATE.md >/dev/null 2>&1; then
  ./scripts/harness/lock-manager.sh release --task-id LOCKTEST --owner check-lock >/dev/null || true
  ./scripts/harness/lock-manager.sh release --task-id LOCKTEST2 --owner check-lock >/dev/null || true
  fail "Overlapping lock acquisition should fail but succeeded"
fi
./scripts/harness/lock-manager.sh release --task-id LOCKTEST --owner check-lock >/dev/null

info "check-lock-protocol passed"
