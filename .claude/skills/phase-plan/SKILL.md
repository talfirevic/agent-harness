---
name: phase-plan
description: Create executable phase plans with wave tasks, write-sets, REQ links, and verification criteria.
---

Execution contract:
1. Read roadmap, requirements, current state, and research.
2. Create `.planning/phases/phase-<N>/PLAN.md`.
3. For every task, include `touches:`, `reads:`, `REQ-###`, and verification command.
4. Keep waves small enough for safe parallel execution by `wave-orchestrator`.
5. Ensure task touches are explicit so `run-wave.sh` can partition non-overlapping work.
