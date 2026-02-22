# Agent-First Harness Playbook

This playbook is self-contained. You can create and run a new complex project from a single idea without manual setup.

## Step 0: One-Command Bootstrap (Idea -> Runnable Repo)

Copy-paste exactly:

```bash
./scripts/bootstrap --idea "<one sentence idea>" --build-now true
```

This command automatically:
- provisions environment files (`.devcontainer/`, `.nvmrc`, `.npmrc`)
- scaffolds repo structure (`.claude/`, `docs/`, `.planning/`, `scripts/`, `tests/`, `src/`)
- installs harness contracts (`skills`, `agents`, `hooks`, CI workflows, lock tooling)
- writes project artifacts (`PROJECT.md`, `REQUIREMENTS.md`, roadmap/state/plan/verification docs)
- runs `make verify` (env gate + knowledge contract + mechanical checks)

## Core Principles and Glossary

- Agent legibility: The app and repo must be bootable, inspectable, and debuggable by agents (`worktree-env`, reproducible scripts, structured evidence).
- Progressive disclosure: Keep `AGENTS.md` short; point to deeper docs and enforced scripts.
- Repo as system of record: Decisions and status live in versioned artifacts, not chat memory.
- Mechanical invariants: Architecture/taste/process rules are encoded in scripts, hooks, and CI.
- Garbage collection: Recurring failures become docs + checks + automation updates.

## Principle-to-Artifact Mapping

| Harness principle | Enforced by |
|---|---|
| Agent-first code execution | `scripts/harness/check-no-manual-code-lane.sh`, `AGENTS.md`, `autonomous-build`, `ship-phase` |
| Repo as system of record | `scripts/harness/check-artifact-sync.sh`, `scripts/harness/docs-lint.sh`, `scripts/harness/knowledge-contract.sh` |
| Application legibility | `scripts/harness/check-legibility.sh`, `scripts/harness/worktree-env.sh`, `scripts/harness/worktree-create.sh` |
| Mechanical invariants | `scripts/harness/check-boundaries.sh`, `check-structural-tests.sh`, `check-taste-invariants.sh`, `check-toolchain-baseline.sh` |
| Parallel-safe delivery | `scripts/harness/lock-manager.sh`, `check-lock-protocol.sh`, `check-parallel-orchestration.sh`, `run-wave.sh` |
| End-to-end autonomous loop | `scripts/harness/ship-phase.sh`, `scripts/harness/run-phase-verify.sh`, `scripts/harness/update-knowledge-loop.sh` |
| Continuous documentation hygiene | `.github/workflows/doc-gardener.yml`, `scripts/harness/knowledge-contract.sh` |

## A) MVP Harness Happy Path (Prescriptive)

### 1. Bootstrap from idea

```bash
./scripts/bootstrap --idea "<one sentence idea>" --build-now true
```

Expected:
- new or updated project scaffold exists
- defaults captured in `.planning/ASSUMPTIONS.md`
- initial plan at `.planning/phases/phase-1/PLAN.md`

### 2. Verify environment and contracts

```bash
./scripts/verify-env
./scripts/harness/knowledge-contract.sh
```

Expected:
- required commands/files present
- docs freshness and REQ<->PLAN<->GAP links valid

### 3. Run full mechanical gates

```bash
make verify
```

Expected:
- readiness, principles, toolchain baseline, lock protocol, docs, traceability all green

### 4. Run autonomous phase loop

```bash
./scripts/harness/ship-phase.sh --phase 1 --parallel auto --dry-run true
```

Expected:
- change classified
- research gate refreshed
- plan validated
- wave tasks partitioned by non-overlapping `touches:`
- worktrees created with deterministic `PORT_BASE`/`DB_SCHEMA`
- locks acquired/released
- verification/simplification/knowledge-update loop completed

### 5. Move from dry-run to live execution

```bash
./scripts/harness/run-wave.sh \
  --plan .planning/phases/phase-1/PLAN.md \
  --wave 1 \
  --dry-run false \
  --executor-cmd "echo implement-task"
```

Expected:
- real execution command runs in isolated worktrees
- optional auto-merge can be enabled with `--auto-merge true`

## Automatic Environment Provisioning (No Manual Prereq Checklist)

Provisioning path used by bootstrap:
- `scripts/harness/provision-env.sh`
- `scripts/harness/verify-env.sh`

Manual fallback (still automated):

```bash
./scripts/provision-env --mode local --install-deps false
./scripts/verify-env
```

For strict local tool installs:

```bash
./scripts/provision-env --mode local --install-deps true
./scripts/verify-env --strict true
```

## Concrete Scaffolder (No Manual mkdir)

Use:

```bash
./scripts/scaffold-harness
```

Creates and/or ensures:
- `.claude/skills/*`, `.claude/agents/*`, `.claude/settings.json`
- `docs/*`, including `docs/_meta/KNOWLEDGE_MAP.yml`
- `.planning/*`, including `.planning/locks/LOCKS.json` and `.planning/gaps/GAP-001.md`

## Enforcement Tooling Bundled by Default

Implemented scripts (not placeholders):
- docs and artifact integrity: `docs-lint.sh`, `check-artifact-sync.sh`, `knowledge-contract.sh`
- requirement traceability: `check-req-coverage.sh`
- invariants: `check-boundaries.sh`, `check-structural-tests.sh`, `check-taste-invariants.sh`
- locking and parallel work: `lock-manager.sh`, `run-wave.sh`, `worktree-create.sh`, `worktree-env.sh`
- conflict resolution: `resolve-overlap.sh` + `docs/runbooks/CONFLICT_RESOLUTION.md`

## Pinned Toolchain Baseline (Default Stack)

Default stack:
- Node `22.x`, npm `10.x`
- TypeScript `5.6.3`
- ESLint `9.17.0`
- Prettier `3.4.2`
- Vitest `2.1.8`

Pinned configs included:
- `package.json`
- `tsconfig.json`
- `eslint.config.mjs`
- `.prettierrc.json`
- `vitest.config.ts`

Top-level commands:
- `./scripts/lint.sh`
- `./scripts/typecheck.sh`
- `./scripts/unit-test.sh`

## Parallelism and Conflict Resolution

Parallel orchestration command:

```bash
./scripts/harness/run-wave.sh --plan .planning/phases/phase-1/PLAN.md --wave 1 --dry-run true
```

Conflict handling command:

```bash
./scripts/harness/resolve-overlap.sh --ours <branch-a> --theirs <branch-b>
```

Protocol:
1. detect lock conflict
2. serialize/replan if needed
3. deterministic rebase
4. merge attempt
5. re-run `make verify`
6. update `.planning/STATE.md` + GAP files

## B) Advanced and Optional Extensions

- Live parallel execution with custom executor command and auto-merge.
- Strict dependency install mode (`--install-deps true`, `--strict true`).
- Scheduled docs hygiene via `.github/workflows/doc-gardener.yml`.
- Packaging harness as reusable plugin bundle after stabilization.

## CI and Local Verification

CI enforces:
- `verify-env`
- `readiness-check`
- principles and invariants
- toolchain baseline
- parallel orchestration gates
- knowledge-contract
- aggregate `check-all`

Local equivalent:

```bash
make verify
```

## References

- OpenAI Harness Engineering: https://openai.com/index/harness-engineering/
- Claude Code Skills: https://code.claude.com/docs/en/skills
- Claude Code Hooks: https://code.claude.com/docs/en/hooks-guide
