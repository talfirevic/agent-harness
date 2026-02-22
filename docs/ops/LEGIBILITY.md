# LEGIBILITY

## Worktree boot
- Use `scripts/dev-up.sh`.
- Assign deterministic ports by worktree identifier.
- Use `scripts/harness/worktree-env.sh` to derive `WORKTREE_ID`, `PORT_BASE`, and `DB_SCHEMA`.

## Observability
- Emit structured logs for runtime and verification commands.
- Keep reproducible steps in task summaries.

## UI evidence
- Capture screenshots and deterministic DOM assertions where applicable.
