---
name: project-from-idea
description: Build a new complex project from one idea by running bootstrap, scaffold, initialization, research, planning, and autonomous build without manual setup.
---

Inputs:
- `idea` (required)
- `stack` (optional)
- `deployment_target` (optional)
- `compliance_profile` (optional)
- `build_now` (default `true`)

Execution contract:
1. Default missing non-blocking inputs and append them to `.planning/ASSUMPTIONS.md`.
2. Ask follow-up questions only for blocker categories in `paybook.md`.
3. Execute the concrete runner script through the one-command wrapper:
   - `./scripts/bootstrap --idea "<idea>" --stack "<stack>" --deployment-target "<target>" --compliance-profile "<profile>" --build-now true`
4. The runner script scaffolds baseline artifacts and writes project-specific docs from inputs.
5. The bootstrap path must run `provision-env.sh` then `verify-env.sh` before any agent work.
6. If `build_now=true`, the runner runs `make verify`.
7. Use `./scripts/harness/ship-phase.sh` as the top-level autonomous loop entrypoint.
8. If requested, run `/autonomous-build --goal mvp --parallel auto`.
9. Commit generated artifacts with traceable messages.
