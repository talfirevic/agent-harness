#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$0")/common.sh"
to_root

require_nonempty_file docs/quality/INVARIANTS.md
require_contains docs/quality/INVARIANTS.md 'Structured logging only'
require_contains docs/quality/INVARIANTS.md 'File size max'

while IFS= read -r f; do
  [[ -n "$f" ]] || continue
  lines="$(wc -l < "$f" | tr -d ' ')"
  if [[ "$lines" -gt 300 ]]; then
    fail "File exceeds 300-line invariant: $f ($lines lines)"
  fi
done < <(find . -type f \
  \( -name '*.ts' -o -name '*.tsx' -o -name '*.js' -o -name '*.jsx' -o -name '*.py' -o -name '*.go' -o -name '*.rs' \) \
  ! -path './.git/*' \
  ! -path './node_modules/*' \
  ! -path './docs/*')

info "check-taste-invariants passed"
