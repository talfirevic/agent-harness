#!/usr/bin/env bash
set -euo pipefail

source "$(dirname "$0")/common.sh"
to_root

OURS=""
THEIRS=""
BASE="main"

usage() {
  cat <<'USAGE'
Usage: ./scripts/harness/resolve-overlap.sh --ours branch-a --theirs branch-b [--base main]
USAGE
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --ours) OURS="$2"; shift 2 ;;
    --ours=*) OURS="${1#*=}"; shift ;;
    --theirs) THEIRS="$2"; shift 2 ;;
    --theirs=*) THEIRS="${1#*=}"; shift ;;
    --base) BASE="$2"; shift 2 ;;
    --base=*) BASE="${1#*=}"; shift ;;
    -h|--help) usage; exit 0 ;;
    *) fail "Unknown argument: $1" ;;
  esac
done

[[ -n "$OURS" ]] || fail "--ours is required"
[[ -n "$THEIRS" ]] || fail "--theirs is required"

require_cmd git

git rev-parse --verify "$OURS" >/dev/null 2>&1 || fail "Branch not found: $OURS"
git rev-parse --verify "$THEIRS" >/dev/null 2>&1 || fail "Branch not found: $THEIRS"

tmp_branch="resolve-$(date +%s)"
git checkout -q "$OURS"
git checkout -q -b "$tmp_branch"

if ! git rebase "$BASE"; then
  fail "Rebase failed. Resolve manually per docs/runbooks/CONFLICT_RESOLUTION.md"
fi

if ! git merge --no-ff "$THEIRS" -m "resolve overlap: $OURS + $THEIRS"; then
  echo "Merge conflict detected. Follow docs/runbooks/CONFLICT_RESOLUTION.md" >&2
  git merge --abort || true
  git checkout -q "$BASE"
  git branch -D "$tmp_branch" >/dev/null 2>&1 || true
  exit 3
fi

./scripts/harness/check-all.sh

git checkout -q "$BASE"
git merge --no-ff "$tmp_branch" -m "merge: resolved overlap for $OURS and $THEIRS"
git branch -D "$tmp_branch" >/dev/null 2>&1 || true

info "resolve-overlap completed"
