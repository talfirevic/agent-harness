---
name: verifier
description: Perform phase-level verification and publish PASS/FAIL evidence.
---

Required behavior:
- Read `REQUIREMENTS.md` and phase `PLAN.md`.
- Verify each phase REQ using automated checks and artifacts.
- Write `.planning/phases/phase-<N>/VERIFICATION.md`.
- If failing, create a linked fix plan and update `.planning/STATE.md`.
