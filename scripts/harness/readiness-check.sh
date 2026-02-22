#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$0")/common.sh"
to_root

required_dirs=(
  .claude/skills
  .claude/agents
  .planning
  .planning/phases
  .planning/locks
  .planning/gaps
  docs
  docs/_meta
  scripts/harness
  src
  tests
  tests/unit
)
for d in "${required_dirs[@]}"; do
  require_dir "$d"
done

required_files=(
  AGENTS.md
  PROJECT.md
  REQUIREMENTS.md
  HARNESS_PRINCIPLES.md
  .claude/settings.json
  .planning/ROADMAP.md
  .planning/STATE.md
  .planning/ASSUMPTIONS.md
  .planning/RESEARCH.md
  docs/architecture/ARCHITECTURE.md
  docs/design/STYLE_GUIDE.md
  docs/quality/INVARIANTS.md
  docs/runbooks/CONFLICT_RESOLUTION.md
  docs/_meta/KNOWLEDGE_MAP.yml
  .planning/gaps/GAP-001.md
  package.json
  tsconfig.json
  eslint.config.mjs
  .prettierrc.json
  vitest.config.ts
  scripts/bootstrap
  scripts/provision-env
  scripts/verify-env
  scripts/scaffold-harness
  Makefile
  .github/workflows/ci.yml
)
for f in "${required_files[@]}"; do
  require_nonempty_file "$f"
done

required_skills=(
  project-from-idea
  bootstrap-harness
  scaffold-project
  project-init-noninteractive
  project-research
  change-classifier
  phase-plan
  autonomous-build
  phase-verify
  project-update-knowledge
  resolve-overlap
  wave-orchestrator
  ship-phase
)
for s in "${required_skills[@]}"; do
  require_nonempty_file ".claude/skills/$s/SKILL.md"
done

required_agents=(
  planner
  executor
  reviewer
  verifier
  doc-gardener
  release-engineer
)
for a in "${required_agents[@]}"; do
  require_nonempty_file ".claude/agents/$a.md"
done

required_checks=(
  scripts/harness/project-from-idea.sh
  scripts/harness/provision-env.sh
  scripts/harness/verify-env.sh
  scripts/harness/scaffold-harness.sh
  scripts/harness/knowledge-contract.sh
  scripts/harness/ship-phase.sh
  scripts/harness/run-wave.sh
  scripts/harness/worktree-create.sh
  scripts/harness/worktree-env.sh
  scripts/harness/lock-manager.sh
  scripts/harness/resolve-overlap.sh
  scripts/harness/check-all.sh
  scripts/harness/check-principles.sh
  scripts/harness/check-toolchain-baseline.sh
  scripts/harness/check-boundaries.sh
  scripts/harness/check-structural-tests.sh
  scripts/harness/check-taste-invariants.sh
  scripts/harness/docs-lint.sh
  scripts/harness/check-artifact-sync.sh
  scripts/harness/check-req-coverage.sh
  scripts/harness/check-parallel-orchestration.sh
)
for c in "${required_checks[@]}"; do
  require_executable "$c"
done

info "readiness-check passed"
