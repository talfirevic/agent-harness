---
name: bootstrap-harness
description: Provision the local environment, scaffold harness artifacts, and verify readiness with no manual setup.
---

Execution contract:
1. Run `./scripts/harness/scaffold-harness.sh`.
2. Run `./scripts/harness/provision-env.sh --mode bootstrap --install-deps false`.
3. Run `./scripts/harness/verify-env.sh`.
4. Run `./scripts/harness/readiness-check.sh`.
5. Stop with explicit remediation if any gate fails.
