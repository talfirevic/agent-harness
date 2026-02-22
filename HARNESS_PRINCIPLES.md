# HARNESS PRINCIPLES

| ID | Principle | Mechanical Enforcement |
|---|---|---|
| HP-001 | Agents write product code; humans steer via docs/prompts/harness | `scripts/harness/check-no-manual-code-lane.sh` |
| HP-002 | Repository artifacts are the system of record | `scripts/harness/check-artifact-sync.sh` + `scripts/harness/docs-lint.sh` + `scripts/harness/knowledge-contract.sh` |
| HP-003 | Application legibility is required for autonomy | `scripts/harness/check-legibility.sh` |
| HP-004 | Architecture and taste invariants are tool-enforced | `scripts/harness/check-boundaries.sh`, `scripts/harness/check-structural-tests.sh`, `scripts/harness/check-taste-invariants.sh`, `scripts/harness/check-toolchain-baseline.sh` |
| HP-005 | Plans and phase state are first-class artifacts | `scripts/harness/check-plan-contract.sh` |
| HP-006 | Parallel work must use lock ownership and overlap resolution | `scripts/harness/check-lock-protocol.sh` + `scripts/harness/check-parallel-orchestration.sh` |
| HP-007 | Verification must be REQ-traceable | `scripts/harness/check-req-coverage.sh` |
| HP-008 | Recurring failures become harness updates | `scripts/harness/check-learning-loop.sh` |
