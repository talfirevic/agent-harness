# Phase 1 PLAN

## Wave 1

### Task T1
- objective: Scaffold required harness and planning artifacts.
- touches:
  - .claude/
  - .planning/
  - docs/
  - scripts/harness/
- reads:
  - paybook.md
  - HARNESS_PRINCIPLES.md
- reqs:
  - REQ-001
  - REQ-002
- verification:
  - ./scripts/harness/readiness-check.sh

### Task T2
- objective: Implement mechanical checks and CI wiring.
- touches:
  - scripts/harness/
  - .github/workflows/
- reads:
  - docs/quality/INVARIANTS.md
  - REQUIREMENTS.md
- reqs:
  - REQ-004
- verification:
  - ./scripts/harness/check-all.sh

## Wave 2

### Task T3
- objective: Define autonomous lane and parallel conflict protocol artifacts.
- touches:
  - .claude/skills/
  - .claude/agents/
  - .planning/locks/LOCKS.json
- reads:
  - .planning/ROADMAP.md
- reqs:
  - REQ-003
  - REQ-005
- verification:
  - ./scripts/harness/check-lock-protocol.sh

## Progress
- Phase seeded.

## Decision Log
- Use shell-based checks for deterministic local and CI validation.

## Surprises
- None.

## Outcomes
- Pending execution evidence and closure of `.planning/gaps/GAP-001.md`.
