#!/usr/bin/env bash
set -euo pipefail

source "$(dirname "$0")/common.sh"
to_root

STRICT="false"
usage() {
  cat <<'USAGE'
Usage: ./scripts/harness/verify-env.sh [--strict true|false]
USAGE
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --strict)
      STRICT="$2"
      shift 2
      ;;
    --strict=*)
      STRICT="${1#*=}"
      shift
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      fail "Unknown argument: $1"
      ;;
  esac
done

case "$STRICT" in
  true|false) ;;
  *) fail "--strict must be true|false" ;;
esac

for cmd in bash sed awk rg git make node npm; do
  require_cmd "$cmd"
done

required_files=(
  .devcontainer/devcontainer.json
  .claude/settings.json
  scripts/harness/provision-env.sh
  scripts/harness/scaffold-harness.sh
  scripts/harness/project-from-idea.sh
  scripts/harness/check-all.sh
  package.json
  tsconfig.json
  eslint.config.mjs
  .prettierrc.json
)
for f in "${required_files[@]}"; do
  require_nonempty_file "$f"
done

if [[ "$STRICT" == "true" ]]; then
  [[ -d node_modules ]] || fail "Strict mode requires node_modules. Run ./scripts/harness/provision-env.sh --install-deps true"
fi

info "verify-env passed"
