---
name: scaffold-project
description: Create the canonical harness directory and seed required docs/planning/quality artifacts automatically.
---

Execution contract:
1. Run `./scripts/harness/scaffold-harness.sh`.
2. Ensure required seed artifacts exist (`AGENTS.md`, `PROJECT.md`, `REQUIREMENTS.md`, docs, planning state).
3. Do not overwrite non-empty user-owned files unless explicitly requested.
4. Report created paths and pass/fail of `./scripts/harness/readiness-check.sh`.
