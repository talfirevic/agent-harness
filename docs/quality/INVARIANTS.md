# INVARIANTS

## Architecture invariants
- Layer rule: Types -> Config -> Repository -> Service -> Runtime -> UI.
- External input must be validated at module boundaries.

## Taste invariants
- Structured logging only.
- File size max: 300 lines unless explicitly exempted.
- Naming conventions must be consistent per language.

## Enforcement policy
- Invariants are enforced by scripts in `scripts/harness/` and CI.
- Parallel write ownership is enforced by `scripts/harness/lock-manager.sh`.
- Deterministic worktree runtime contracts are enforced by `scripts/harness/worktree-env.sh`.
