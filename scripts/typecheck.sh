#!/usr/bin/env bash
set -euo pipefail

if [[ -d node_modules ]]; then
  npm run -s typecheck:node
else
  echo "[toolchain] node_modules missing; running fallback typecheck gate"
  test -f tsconfig.json
  ./scripts/harness/check-structural-tests.sh
fi
