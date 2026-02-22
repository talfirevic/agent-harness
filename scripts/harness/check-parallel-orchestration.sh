#!/usr/bin/env bash
set -euo pipefail

source "$(dirname "$0")/common.sh"
to_root

require_executable scripts/harness/run-wave.sh
require_executable scripts/harness/worktree-create.sh
require_executable scripts/harness/worktree-env.sh
require_executable scripts/harness/lock-manager.sh
require_nonempty_file .claude/skills/wave-orchestrator/SKILL.md

# lock manager smoke test
./scripts/harness/lock-manager.sh acquire --task-id SELFTEST --owner check --branch check-self --touches .planning/STATE.md >/dev/null
if ./scripts/harness/lock-manager.sh acquire --task-id SELFTEST2 --owner check --branch check-self-2 --touches .planning/STATE.md >/dev/null 2>&1; then
  ./scripts/harness/lock-manager.sh release --task-id SELFTEST --owner check >/dev/null || true
  ./scripts/harness/lock-manager.sh release --task-id SELFTEST2 --owner check >/dev/null || true
  fail "lock-manager should reject overlapping lock acquisition"
fi
./scripts/harness/lock-manager.sh release --task-id SELFTEST --owner check >/dev/null

info "check-parallel-orchestration passed"
