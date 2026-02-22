#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$0")/common.sh"
to_root

required_docs=(
  docs/README.md
  docs/architecture/ARCHITECTURE.md
  docs/design/STYLE_GUIDE.md
  docs/quality/INVARIANTS.md
  docs/ops/LEGIBILITY.md
  docs/runbooks/DEPLOY.md
)
for d in "${required_docs[@]}"; do
  require_nonempty_file "$d"
done

# Basic local markdown link checks for links like [text](path)
while IFS= read -r line; do
  file="${line%%:*}"
  rest="${line#*:}"
  target="$(printf '%s' "$rest" | sed -E 's/.*\[[^]]+\]\(([^)]+)\).*/\1/')"

  case "$target" in
    http*|mailto:*|"#"*|"")
      continue
      ;;
  esac

  clean_target="${target%%#*}"
  if [[ "$clean_target" == /* ]]; then
    continue
  fi

  dir="$(dirname "$file")"
  if [[ ! -e "$dir/$clean_target" ]]; then
    fail "Broken local markdown link in $file -> $target"
  fi
done < <(rg -n '\[[^]]+\]\([^)]+\)' --glob '*.md' .)

info "docs-lint passed"
