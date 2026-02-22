#!/usr/bin/env bash
set -euo pipefail

source "$(dirname "$0")/common.sh"
to_root

BRANCH=""
BASE_BRANCH="main"
PATH_ARG=""

usage() {
  cat <<'USAGE'
Usage: ./scripts/harness/worktree-create.sh --branch wave-1-t1 [--base-branch main] [--path .worktrees/wave-1-t1]
USAGE
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --branch)
      BRANCH="$2"
      shift 2
      ;;
    --branch=*)
      BRANCH="${1#*=}"
      shift
      ;;
    --base-branch)
      BASE_BRANCH="$2"
      shift 2
      ;;
    --base-branch=*)
      BASE_BRANCH="${1#*=}"
      shift
      ;;
    --path)
      PATH_ARG="$2"
      shift 2
      ;;
    --path=*)
      PATH_ARG="${1#*=}"
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

[[ -n "$BRANCH" ]] || fail "--branch is required"
[[ -n "$PATH_ARG" ]] || PATH_ARG=".worktrees/$BRANCH"

require_cmd git

if ! git rev-parse --verify "$BASE_BRANCH" >/dev/null 2>&1; then
  detected_branch="$(git rev-parse --abbrev-ref HEAD 2>/dev/null || true)"
  if [[ -n "$detected_branch" && "$detected_branch" != "HEAD" ]]; then
    BASE_BRANCH="$detected_branch"
  fi
fi

git rev-parse --verify "$BASE_BRANCH" >/dev/null 2>&1 || fail "Base branch not found: $BASE_BRANCH"

if [[ -d "$PATH_ARG/.git" || -f "$PATH_ARG/.git" ]]; then
  info "worktree already exists: $PATH_ARG"
else
  if ! git show-ref --verify --quiet "refs/heads/$BRANCH"; then
    git branch "$BRANCH" "$BASE_BRANCH"
  fi
  git worktree add "$PATH_ARG" "$BRANCH"
fi

mkdir -p "$PATH_ARG/.tmp"
./scripts/harness/worktree-env.sh --worktree-id "$BRANCH" --format env > "$PATH_ARG/.worktree.env"

info "worktree-create completed: $PATH_ARG"
