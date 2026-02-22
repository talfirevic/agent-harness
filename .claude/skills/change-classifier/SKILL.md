---
name: change-classifier
description: Route incoming work to bugfix, incremental feature, or pivot lanes with explicit artifact impact.
---

Execution contract:
1. Read request + `PROJECT.md` + `REQUIREMENTS.md` + `.planning/STATE.md`.
2. Classify lane: `bugfix`, `incremental`, or `pivot`.
3. Emit impacted artifacts and required checks.
4. For small bounded updates, allow MICRO_PLAN path; otherwise require full phase plan.
5. Write lane decision via `./scripts/harness/change-classify.sh --request "<text>"`.
