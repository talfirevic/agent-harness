#!/usr/bin/env bash
set -euo pipefail

payload="$(cat || true)"

if command -v rg >/dev/null 2>&1; then
  matcher='"file_path"\s*:\s*"[^"]*(\.env|package-lock\.json|pnpm-lock\.yaml|yarn\.lock)"'
  if printf '%s' "$payload" | rg -q "$matcher"; then
    echo "Blocked edit to protected file by harness policy." >&2
    exit 2
  fi
else
  if printf '%s' "$payload" | grep -Eq '"file_path"[[:space:]]*:[[:space:]]*"[^"]*(\.env|package-lock\.json|pnpm-lock\.yaml|yarn\.lock)"'; then
    echo "Blocked edit to protected file by harness policy." >&2
    exit 2
  fi
fi

exit 0
