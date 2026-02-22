---
name: autonomous-build
description: Execute an end-to-end autonomous phase loop (classify, research, plan, parallel wave execution, verify, simplify, update knowledge).
---

Execution contract:
1. Run `./scripts/harness/ship-phase.sh --phase 1 --parallel auto --dry-run true` by default.
2. For live execution, run with `--dry-run false` and provide an executor command to `run-wave`.
3. Require green harness gates before merge.
4. Humans are consulted only for explicit blocker categories.
5. Manual code writing is prohibited in this lane.
