# FLAKE POLICY

1. Allow at most 2 automatic retries for known flaky checks.
2. If still failing, quarantine with a tracked `GAP-###` in `.planning/STATE.md`.
3. Add or tighten a deterministic check to prevent recurrence.
