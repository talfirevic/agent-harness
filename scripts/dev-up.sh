#!/usr/bin/env bash
set -euo pipefail

if [[ "${1:-}" == "--check" ]]; then
  echo "dev-up check: ok"
  exit 0
fi

echo "dev-up placeholder: integrate app boot command here."
