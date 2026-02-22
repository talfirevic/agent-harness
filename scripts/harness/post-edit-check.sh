#!/usr/bin/env bash
set -euo pipefail

./scripts/harness/check-toolchain-baseline.sh >/dev/null
./scripts/harness/check-boundaries.sh >/dev/null
echo "[harness] post-edit hook checks passed"
