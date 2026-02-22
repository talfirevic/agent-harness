# CONFLICT RESOLUTION RUNBOOK

1. Detect overlap from lock manager conflict output (`status: conflict`).
2. Serialize overlapping tasks and release stale locks.
3. Rebase each branch onto `main` in deterministic order.
4. Run `./scripts/harness/resolve-overlap.sh --ours <branch-a> --theirs <branch-b>`.
5. Re-run `./scripts/harness/check-all.sh` and `./scripts/harness/knowledge-contract.sh`.
6. Update `.planning/STATE.md` and link any residual issue to `.planning/gaps/GAP-###.md`.
7. Escalate to human only for policy/legal/product-decision conflicts.
