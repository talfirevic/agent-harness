# Agent-First Harness

Agent-First Harness is an operating model for autonomous software delivery.
Humans define intent and constraints, agents implement, and repository artifacts stay
as the source of truth for scope, status, and verification.

It is designed to reduce ad-hoc "vibe coding" drift by enforcing planning, ownership,
and quality gates mechanically.

[Install](#install-in-an-existing-repository-web-installer) | [First 10 Minutes](#first-10-minutes) | [How It Works](#how-it-works) | [Commands](#core-commands) | [Troubleshooting](#troubleshooting) | [Playbook](#read-next)

## What You Get

- Idea to structured project bootstrap in one command.
- Artifact-first delivery (`PROJECT.md`, `REQUIREMENTS.md`, `.planning/*`).
- Parallel-safe execution with explicit `touches:` ownership.
- Mechanical quality and architecture enforcement before merge.
- Continuous learning loop from failures into harness updates.

## Who This Is For

- Teams that want agents writing product code with clear human steering.
- Builders who need auditable requirements, plans, and phase state.
- Projects where parallel execution speed matters but safety cannot regress.

Not for fully unsupervised production decision-making.

## Install in an Existing Repository (Web Installer)

Run from the root of the repository where you want the harness:

```bash
curl -fsSL https://raw.githubusercontent.com/talfirevic/agent-harness/main/install.sh | bash
```

Verify installation:

```bash
./scripts/harness/readiness-check.sh
./scripts/harness/check-all.sh
```

Update later by running the same installer command again.

## First 10 Minutes

1. Bootstrap from your idea.

```bash
./scripts/bootstrap --idea "<one sentence idea>" --build-now true
```

Expected: scaffolded project structure, planning docs, and initial phase plan.

2. Run verification gates.

```bash
make verify
```

Expected: readiness + principles + contract checks pass locally.

3. Dry-run the first autonomous phase.

```bash
./scripts/harness/ship-phase.sh --phase 1 --parallel auto --dry-run true
```

Expected: execution plan partitioned by `touches:`, work prepared safely.

4. Execute your first wave.

```bash
./scripts/harness/run-wave.sh --plan .planning/phases/phase-1/PLAN.md --wave 1 --dry-run false
```

Expected: tasks run in isolated lanes with verification and state updates.

## How It Works

1. Define: capture intent and constraints in `PROJECT.md` and `REQUIREMENTS.md`.
2. Plan: maintain phase plans and ownership in `.planning/phases/*` using `touches:`.
3. Execute: run autonomous phases/waves with harness orchestration scripts.
4. Verify: enforce quality, architecture, and traceability through `make verify` and CI.
5. Learn: update `.planning/STATE.md` and gap docs so recurring issues become harness improvements.

## Core Commands

| Command | Use it when |
|---|---|
| `./scripts/bootstrap --idea "<idea>" --build-now true` | Starting or resetting a project from a clear idea |
| `make verify` | Running full local verification before merge |
| `./scripts/harness/ship-phase.sh --phase 1 --parallel auto --dry-run true` | Planning and validating a phase before real execution |
| `./scripts/harness/run-wave.sh --plan .planning/phases/phase-1/PLAN.md --wave 1 --dry-run false` | Running actual wave tasks |
| `./scripts/harness/resolve-overlap.sh --ours <branch-a> --theirs <branch-b>` | Resolving overlapping parallel work safely |

## Troubleshooting

- Installer completed but scripts are missing:
  re-run installer from repo root and then run `./scripts/harness/readiness-check.sh`.
- Verification fails locally:
  run `make verify` and fix first failing gate before continuing.
- Parallel branches overlap:
  use `./scripts/harness/resolve-overlap.sh` and re-run `make verify`.
- Need latest harness behavior:
  re-run the web installer to pull updated managed files.

## Read Next

- `playbook.md`: detailed operating flow and rationale.
- `PROJECT.md`: problem statement, scope, and success criteria.
- `REQUIREMENTS.md`: `REQ-*` requirements and acceptance criteria.
- `HARNESS_PRINCIPLES.md`: principle-to-enforcement mapping.
- `.planning/STATE.md`: current milestone, phase, and open gaps.

## Inspiration

- OpenAI Harness Engineering: [https://openai.com/index/harness-engineering/](https://openai.com/index/harness-engineering/)
- Selected concepts adapted from: [https://github.com/gsd-build/get-shit-done](https://github.com/gsd-build/get-shit-done)

## Requirement Traceability

This repository implements `REQ-001` through `REQ-005`.
See `REQUIREMENTS.md` for full acceptance criteria.
