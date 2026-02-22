#!/usr/bin/env bash
set -euo pipefail

source "$(dirname "$0")/common.sh"
to_root

PLAN_PATH=".planning/phases/phase-1/PLAN.md"
WAVE="1"
BASE_BRANCH="main"
AUTO_MERGE="false"
DRY_RUN="true"
OWNER="wave-orchestrator"
EXECUTOR_CMD=""

usage() {
  cat <<'USAGE'
Usage: ./scripts/harness/run-wave.sh [options]

Options:
  --plan PATH               PLAN.md path (default .planning/phases/phase-1/PLAN.md)
  --wave N                  Wave number to execute (default 1)
  --base-branch BRANCH      Base branch for worktrees (default main)
  --auto-merge true|false   Auto-merge approved task branches (default false)
  --dry-run true|false      If true, only scaffold task execution artifacts (default true)
  --owner NAME              Lock owner id (default wave-orchestrator)
  --executor-cmd CMD        Command run in each worktree when dry-run=false
USAGE
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --plan) PLAN_PATH="$2"; shift 2 ;;
    --plan=*) PLAN_PATH="${1#*=}"; shift ;;
    --wave) WAVE="$2"; shift 2 ;;
    --wave=*) WAVE="${1#*=}"; shift ;;
    --base-branch) BASE_BRANCH="$2"; shift 2 ;;
    --base-branch=*) BASE_BRANCH="${1#*=}"; shift ;;
    --auto-merge) AUTO_MERGE="$2"; shift 2 ;;
    --auto-merge=*) AUTO_MERGE="${1#*=}"; shift ;;
    --dry-run) DRY_RUN="$2"; shift 2 ;;
    --dry-run=*) DRY_RUN="${1#*=}"; shift ;;
    --owner) OWNER="$2"; shift 2 ;;
    --owner=*) OWNER="${1#*=}"; shift ;;
    --executor-cmd) EXECUTOR_CMD="$2"; shift 2 ;;
    --executor-cmd=*) EXECUTOR_CMD="${1#*=}"; shift ;;
    -h|--help) usage; exit 0 ;;
    *) fail "Unknown argument: $1" ;;
  esac
done

case "$AUTO_MERGE" in true|false) ;; *) fail "--auto-merge must be true|false" ;; esac
case "$DRY_RUN" in true|false) ;; *) fail "--dry-run must be true|false" ;; esac

require_nonempty_file "$PLAN_PATH"
require_executable scripts/harness/worktree-create.sh
require_executable scripts/harness/worktree-env.sh
require_executable scripts/harness/lock-manager.sh

if ! git rev-parse --verify "$BASE_BRANCH" >/dev/null 2>&1; then
  detected_branch="$(git rev-parse --abbrev-ref HEAD 2>/dev/null || true)"
  if [[ -n "$detected_branch" && "$detected_branch" != "HEAD" ]]; then
    BASE_BRANCH="$detected_branch"
  fi
fi

TMP_DIR_PATH="$(mktemp -d)"
trap 'rm -rf "$TMP_DIR_PATH"' EXIT

awk -v wave="$WAVE" '
BEGIN { inwave=0; task=""; mode="" }
$0 ~ /^## Wave / {
  if ($0 ~ "^## Wave " wave "$") { inwave=1; next }
  if (inwave==1) { exit }
}
inwave==1 {
  if ($0 ~ /^### Task /) {
    task=$3
    print "TASK\t" task
    mode=""
    next
  }
  if ($0 ~ /^- touches:/) { mode="touches"; next }
  if ($0 ~ /^- reads:/ || $0 ~ /^- reqs:/ || $0 ~ /^- verification:/) { mode=""; next }
  if (mode=="touches" && $0 ~ /^  - /) {
    touch=$0
    sub(/^  - /, "", touch)
    print "TOUCH\t" task "\t" touch
  }
}
' "$PLAN_PATH" > "$TMP_DIR_PATH/parsed.tsv"

if [[ ! -s "$TMP_DIR_PATH/parsed.tsv" ]]; then
  fail "No tasks found for wave $WAVE in $PLAN_PATH"
fi

awk -F'\t' '$1=="TASK" {print $2}' "$TMP_DIR_PATH/parsed.tsv" > "$TMP_DIR_PATH/tasks.list"

lane_count=0
while IFS= read -r task; do
  [[ -n "$task" ]] || continue

  awk -F'\t' -v t="$task" '$1=="TOUCH" && $2==t {print $3}' "$TMP_DIR_PATH/parsed.tsv" > "$TMP_DIR_PATH/$task.touches"
  assigned_lane=""

  lane=1
  while [[ "$lane" -le "$lane_count" ]]; do
    lane_file="$TMP_DIR_PATH/lane-$lane.touches"
    if [[ ! -s "$lane_file" ]]; then
      assigned_lane="$lane"
      break
    fi

    if ! grep -Fxf "$TMP_DIR_PATH/$task.touches" "$lane_file" >/dev/null 2>&1; then
      assigned_lane="$lane"
      break
    fi

    lane=$((lane + 1))
  done

  if [[ -z "$assigned_lane" ]]; then
    lane_count=$((lane_count + 1))
    assigned_lane="$lane_count"
    : > "$TMP_DIR_PATH/lane-$assigned_lane.touches"
    : > "$TMP_DIR_PATH/lane-$assigned_lane.tasks"
  fi

  cat "$TMP_DIR_PATH/$task.touches" >> "$TMP_DIR_PATH/lane-$assigned_lane.touches"
  sort -u "$TMP_DIR_PATH/lane-$assigned_lane.touches" > "$TMP_DIR_PATH/lane-$assigned_lane.touches.sorted"
  mv "$TMP_DIR_PATH/lane-$assigned_lane.touches.sorted" "$TMP_DIR_PATH/lane-$assigned_lane.touches"
  echo "$task" >> "$TMP_DIR_PATH/lane-$assigned_lane.tasks"

done < "$TMP_DIR_PATH/tasks.list"

info "Wave partition complete: $lane_count lane(s)"

pids_file="$TMP_DIR_PATH/pids.list"
: > "$pids_file"

run_task() {
  local task="$1"
  local branch="wave${WAVE}-$(printf '%s' "$task" | tr '[:upper:]' '[:lower:]' | sed -E 's/[^a-z0-9]+/-/g')"
  local worktree_path=".worktrees/$branch"
  local touches_csv

  touches_csv="$(awk -F'\t' -v t="$task" '$1=="TOUCH" && $2==t {print $3}' "$TMP_DIR_PATH/parsed.tsv" | paste -sd, -)"
  [[ -n "$touches_csv" ]] || fail "Task $task has no touches set"

  ./scripts/harness/worktree-create.sh --branch "$branch" --base-branch "$BASE_BRANCH" --path "$worktree_path"
  ./scripts/harness/lock-manager.sh acquire --task-id "$task" --owner "$OWNER" --branch "$branch" --touches "$touches_csv"

  mkdir -p "$worktree_path/.planning/tasks/$task"
  if [[ "$DRY_RUN" == "true" ]]; then
    cat > "$worktree_path/.planning/tasks/$task/SUMMARY.md" <<SUMMARY
# $task

status: APPROVED
mode: dry-run
worktree: $worktree_path
touches: $touches_csv
SUMMARY
  else
    if [[ -z "$EXECUTOR_CMD" ]]; then
      fail "--executor-cmd is required when --dry-run=false"
    fi

    (
      cd "$worktree_path"
      eval "$EXECUTOR_CMD"
    )

    cat > "$worktree_path/.planning/tasks/$task/SUMMARY.md" <<SUMMARY
# $task

status: APPROVED
mode: execute
worktree: $worktree_path
touches: $touches_csv
executor_cmd: $EXECUTOR_CMD
SUMMARY
  fi

  ./scripts/harness/lock-manager.sh release --task-id "$task" --owner "$OWNER" >/dev/null

  if [[ "$AUTO_MERGE" == "true" ]]; then
    if [[ "$(rg -n 'status:[[:space:]]*APPROVED' "$worktree_path/.planning/tasks/$task/SUMMARY.md" || true)" != "" ]]; then
      git -C "$worktree_path" rebase "$BASE_BRANCH" >/dev/null 2>&1 || true
      if [[ -n "$(git -C "$worktree_path" log --oneline "$BASE_BRANCH"..HEAD 2>/dev/null || true)" ]]; then
        git checkout "$BASE_BRANCH" >/dev/null 2>&1
        git merge --no-ff "$branch" -m "merge: wave $WAVE task $task" >/dev/null 2>&1 || true
      fi
    fi
  fi
}

lane=1
while [[ "$lane" -le "$lane_count" ]]; do
  lane_tasks_file="$TMP_DIR_PATH/lane-$lane.tasks"
  while IFS= read -r task; do
    [[ -n "$task" ]] || continue
    run_task "$task" &
    echo "$!" >> "$pids_file"
  done < "$lane_tasks_file"
  lane=$((lane + 1))
done

failed=0
while IFS= read -r pid; do
  [[ -n "$pid" ]] || continue
  if ! wait "$pid"; then
    failed=1
  fi
done < "$pids_file"

if [[ "$failed" -ne 0 ]]; then
  fail "run-wave failed for one or more tasks"
fi

info "run-wave completed for wave $WAVE"
