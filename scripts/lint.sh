#!/usr/bin/env bash
set -euo pipefail

if [[ -d node_modules ]]; then
  npm run -s lint:node
else
  echo "[toolchain] node_modules missing; running fallback lint checks"
  ./scripts/harness/check-boundaries.sh
  ./scripts/harness/check-taste-invariants.sh
fi
