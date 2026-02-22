---
name: wave-orchestrator
description: Partition phase tasks by non-overlapping write-sets, create isolated worktrees, acquire locks, execute tasks in parallel, and optionally auto-merge approved branches.
---

Execution contract:
1. Read `.planning/phases/phase-<N>/PLAN.md` and wave number.
2. Run `./scripts/harness/run-wave.sh --plan <PLAN.md> --wave <N> --dry-run true`.
3. Use `--dry-run false` for real execution and provide executor command.
4. Ensure locks are acquired and released with `lock-manager.sh`.
5. Use deterministic worktree env from `worktree-env.sh`.
