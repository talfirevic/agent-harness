---
name: resolve-overlap
description: Resolve overlapping write-set conflicts with deterministic rebase, merge, and invariant re-validation.
---

Execution contract:
1. Detect lock collisions via `./scripts/harness/lock-manager.sh` output.
2. Run `./scripts/harness/resolve-overlap.sh --ours <branch-a> --theirs <branch-b>`.
3. Re-run `./scripts/harness/check-all.sh` and `./scripts/harness/knowledge-contract.sh`.
4. Update `.planning/STATE.md` and link unresolved issues to `.planning/gaps/GAP-###.md`.
