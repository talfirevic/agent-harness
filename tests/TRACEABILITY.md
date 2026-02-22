# Traceability

| REQ | Verification Command |
|---|---|
| REQ-001 | `./scripts/harness/readiness-check.sh` |
| REQ-002 | `./scripts/verify-env` |
| REQ-003 | `./scripts/harness/run-wave.sh --wave 1 --dry-run true` |
| REQ-004 | `make verify` |
| REQ-005 | `./scripts/harness/ship-phase.sh --phase 1 --parallel auto --dry-run true` |
