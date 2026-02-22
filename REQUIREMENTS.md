# REQUIREMENTS

| ID | Requirement | Acceptance Criteria | Status |
|---|---|---|---|
| REQ-001 | One-command project creation | `project-from-idea` creates required docs, planning state, and scaffold in one run | active |
| REQ-002 | Automatic harness setup | Skills, agents, hooks, and required checks are installed with no manual steps | active |
| REQ-003 | Parallel-safe execution | Tasks declare `touches:` and conflicts are resolved with lock protocol and deterministic retries | active |
| REQ-004 | Mechanical quality gates | CI runs readiness, principles, lint/structure/taste/docs/artifact/coverage checks | active |
| REQ-005 | Autonomous delivery lane | `autonomous-build` can complete plan->implement->verify->merge without manual product coding | active |
