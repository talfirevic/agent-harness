# Agent-First Harness

This repository defines a practical operating model for autonomous software delivery:
humans set intent and constraints, agents perform implementation, and repository artifacts
are the system of record for decisions, progress, and verification.

## Inspiration

This work is inspired by OpenAI's [Harness Engineering](https://openai.com/index/harness-engineering/).
It also incorporates selected concepts from [gsd-build/get-shit-done](https://github.com/gsd-build/get-shit-done),
especially artifact-first planning, mechanical quality gates, and disciplined execution loops.

## At a Glance

- Start from one idea, not a manual setup checklist.
- Keep plans, requirements, and phase state as versioned artifacts.
- Run agents in parallel with explicit write ownership (`touches:`).
- Enforce architecture, quality, and documentation rules mechanically.
- Convert recurring failures into harness improvements.

## What This Project Is About

The core concept is not "run a script." The core concept is a repeatable delivery model
for complex projects where:

- product intent starts from one clear idea
- plans and requirements are codified as versioned artifacts
- agents execute work in parallel with explicit ownership (`touches:`)
- quality, architecture, and documentation invariants are mechanically enforced
- failures feed back into harness updates instead of being rediscovered

The harness turns autonomy from a one-off prompt exercise into an auditable system.

## Why Teams Use It

- Faster idea-to-project bootstrapping without ad-hoc setup work
- Safer parallel agent execution with lock ownership and overlap resolution
- Predictable quality through mandatory local + CI verification gates
- Better continuity because state lives in docs and plans, not transient chat context

## Core Operating Model

1. Human defines direction and priority.
2. Repo artifacts define scope and constraints (`PROJECT.md`, `REQUIREMENTS.md`, `.planning/*`).
3. Agents implement product code inside the harness lane.
4. Mechanical checks validate invariants before merge.
5. Phase state and knowledge artifacts are updated after execution.

This model aligns directly with harness principles in
`HARNESS_PRINCIPLES.md` and invariants in `docs/quality/INVARIANTS.md`.

## Quickstart (Concept-to-Execution)

From a repository with the harness installed:

```bash
./scripts/bootstrap --idea "<one sentence idea>" --build-now true
make verify
./scripts/harness/ship-phase.sh --phase 1 --parallel auto --dry-run true
```

Expected outcome:

- scaffolded project artifacts and planning state
- environment and quality contracts verified
- first autonomous phase run planned and validated in dry-run mode

Then move from dry-run to execution with `./scripts/harness/run-wave.sh`.

## Day-to-Day Workflow

1. Update intent and scope in `PROJECT.md`, `REQUIREMENTS.md`, and `.planning/phases/*`.
2. Ensure each task declares `touches:` ownership for parallel safety.
3. Run `make verify` before merge.
4. Use phase and wave commands to execute autonomous work.
5. Record results in `.planning/STATE.md` and relevant gap docs.

## Key Artifacts to Read First

- `playbook.md`: end-to-end operating playbook
- `PROJECT.md`: product problem, scope, success metrics
- `REQUIREMENTS.md`: requirement contract (`REQ-*`)
- `HARNESS_PRINCIPLES.md`: behavior principles and enforcement mapping
- `.planning/STATE.md`: current milestone, phase, gaps, blockers

## Requirement Traceability

This harness supports:

- `REQ-001`: one-command project creation
- `REQ-002`: automatic harness setup
- `REQ-003`: parallel-safe execution
- `REQ-004`: mechanical quality gates
- `REQ-005`: autonomous delivery lane

See `REQUIREMENTS.md` for acceptance criteria.
