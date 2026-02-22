---
name: phase-verify
description: Verify phase outcomes using REQ-traceable checks and produce PASS/FAIL evidence.
---

Execution contract:
1. Read requirements and phase plan.
2. Run `./scripts/harness/run-phase-verify.sh --phase <N>`.
3. Validate UI and non-UI evidence against project contracts.
4. Write `.planning/phases/phase-<N>/VERIFICATION.md`.
