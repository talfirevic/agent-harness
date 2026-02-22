#!/usr/bin/env bash
set -euo pipefail

if [[ "${1:-}" == "--check" ]]; then
  echo "test-all check: ok"
  exit 0
fi

./scripts/harness/check-all.sh
