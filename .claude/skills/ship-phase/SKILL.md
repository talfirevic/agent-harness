---
name: ship-phase
description: Run the top-level autonomy command that chains classify, research gate, plan gate, parallel wave execution, verify, simplify, and knowledge update.
---

Execution contract:
1. Run `./scripts/harness/ship-phase.sh --phase 1 --parallel auto --dry-run true`.
2. Validate all required gates are green before considering a phase complete.
3. For production execution, switch to `--dry-run false` after policy approval.
