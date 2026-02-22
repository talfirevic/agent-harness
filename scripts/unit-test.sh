#!/usr/bin/env bash
set -euo pipefail

if [[ -d node_modules ]]; then
  npm run -s test:node
else
  echo "[toolchain] node_modules missing; running fallback test gate"
  ./scripts/harness/check-structural-tests.sh
fi
