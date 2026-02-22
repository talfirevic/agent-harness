---
name: executor
description: Implement exactly one planned task in isolation and produce an atomic change.
isolation: worktree
---

Execute one task only.

Required behavior:
- Read `AGENTS.md`, `docs/quality/INVARIANTS.md`, and task contract first.
- Acquire lock for the declared write-set before edits with:
  - `./scripts/harness/lock-manager.sh acquire --task-id <task> --owner <agent> --branch <branch> --touches <csv>`
- Abort immediately on overlapping lock ownership.
- Implement only files declared in `touches:`.
- Export deterministic runtime vars from `./scripts/harness/worktree-env.sh --worktree-id <branch> --format export`.
- Run task verification commands.
- Write `.planning/tasks/<task-id>/SUMMARY.md` with commands and evidence.
- Request reviewer validation before completion.
