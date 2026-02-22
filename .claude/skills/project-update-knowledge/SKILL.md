---
name: project-update-knowledge
description: Convert repeated failures and review findings into durable docs, checks, hooks, or tests.
---

Execution contract:
1. Read verification failures, logs, and reviewer findings.
2. Update docs and add or tighten mechanical checks.
3. Update `docs/quality/SCORECARD.md` and `docs/quality/FLAKE_POLICY.md` when relevant.
4. Re-run `./scripts/harness/knowledge-contract.sh`.
5. Commit harness improvements.
