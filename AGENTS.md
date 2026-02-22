# AGENTS.md

## Sources of Truth
- Product contract: `PROJECT.md`
- Requirements: `REQUIREMENTS.md`
- Harness principles: `HARNESS_PRINCIPLES.md`
- Architecture: `docs/architecture/ARCHITECTURE.md`
- Quality invariants: `docs/quality/INVARIANTS.md`
- Planning state: `.planning/STATE.md`

## Operating Rules
1. Agents author product code by default.
2. Humans set priorities and handle blocker decisions.
3. Humans do not manually write product code in normal flow.
4. Every change must map to one or more `REQ-###` IDs.
5. Every task must declare write-set ownership via `touches:`.
6. Merge requires green harness checks.

## Bootstrap
- One-command setup: `./scripts/bootstrap --idea "<one sentence idea>" --build-now true`
- Local verification: `make verify`
