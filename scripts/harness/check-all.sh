#!/usr/bin/env bash
set -euo pipefail

./scripts/harness/verify-env.sh
./scripts/harness/readiness-check.sh
./scripts/harness/check-principles.sh
./scripts/harness/check-toolchain-baseline.sh
./scripts/harness/check-boundaries.sh
./scripts/harness/check-structural-tests.sh
./scripts/harness/check-taste-invariants.sh
./scripts/harness/docs-lint.sh
./scripts/harness/check-artifact-sync.sh
./scripts/harness/check-req-coverage.sh
./scripts/harness/check-parallel-orchestration.sh
./scripts/harness/knowledge-contract.sh
./scripts/harness/check-learning-loop.sh
./scripts/lint.sh
./scripts/typecheck.sh
./scripts/unit-test.sh

echo "[harness] check-all passed"
