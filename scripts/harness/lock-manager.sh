#!/usr/bin/env bash
set -euo pipefail

source "$(dirname "$0")/common.sh"
to_root

LOCK_FILE=".planning/locks/LOCKS.json"
LOCK_DIR=".planning/locks/.lockdir"

usage() {
  cat <<'USAGE'
Usage:
  ./scripts/harness/lock-manager.sh acquire --task-id T1 --owner agent --branch my-branch --touches path1,path2
  ./scripts/harness/lock-manager.sh release --task-id T1 [--owner agent]
  ./scripts/harness/lock-manager.sh list
USAGE
}

acquire_fs_lock() {
  local attempts=0
  while ! mkdir "$LOCK_DIR" 2>/dev/null; do
    attempts=$((attempts + 1))
    if [[ "$attempts" -gt 200 ]]; then
      fail "Timed out waiting for lock file"
    fi
    sleep 0.05
  done
}

release_fs_lock() {
  rmdir "$LOCK_DIR" 2>/dev/null || true
}

run_node_lock_update() {
  local action="$1"
  shift
  ACTION="$action" LOCK_FILE="$LOCK_FILE" node - "$@" <<'NODE'
const fs = require('fs');

const action = process.env.ACTION;
const lockFile = process.env.LOCK_FILE;
const args = process.argv.slice(2);

function parseArgs(argv) {
  const out = {};
  for (let i = 0; i < argv.length; i += 1) {
    const key = argv[i];
    const next = argv[i + 1];
    if (!key.startsWith('--')) continue;
    out[key.slice(2)] = next;
    i += 1;
  }
  return out;
}

if (!fs.existsSync(lockFile)) {
  fs.writeFileSync(lockFile, JSON.stringify({ locks: [] }, null, 2) + '\n');
}

const data = JSON.parse(fs.readFileSync(lockFile, 'utf8'));
if (!Array.isArray(data.locks)) data.locks = [];

const now = new Date().toISOString();
const options = parseArgs(args);

if (action === 'acquire') {
  const taskId = options['task-id'];
  const owner = options['owner'];
  const branch = options['branch'];
  const touches = (options['touches'] || '').split(',').map((x) => x.trim()).filter(Boolean);

  if (!taskId || !owner || !branch || touches.length === 0) {
    console.error('acquire requires --task-id --owner --branch --touches');
    process.exit(2);
  }

  const conflicts = [];
  for (const path of touches) {
    const existing = data.locks.find((item) => item.path === path && !(item.task_id === taskId && item.owner === owner));
    if (existing) {
      conflicts.push({ path, task_id: existing.task_id, owner: existing.owner, branch: existing.branch });
    }
  }

  if (conflicts.length > 0) {
    console.error(JSON.stringify({ status: 'conflict', conflicts }, null, 2));
    process.exit(3);
  }

  for (const path of touches) {
    data.locks.push({ path, task_id: taskId, owner, branch, acquired_at: now });
  }

  fs.writeFileSync(lockFile, JSON.stringify(data, null, 2) + '\n');
  console.log(JSON.stringify({ status: 'acquired', task_id: taskId, lock_count: touches.length }));
  process.exit(0);
}

if (action === 'release') {
  const taskId = options['task-id'];
  const owner = options['owner'] || '';

  if (!taskId) {
    console.error('release requires --task-id');
    process.exit(2);
  }

  const before = data.locks.length;
  data.locks = data.locks.filter((item) => {
    if (item.task_id !== taskId) return true;
    if (owner && item.owner !== owner) return true;
    return false;
  });

  fs.writeFileSync(lockFile, JSON.stringify(data, null, 2) + '\n');
  console.log(JSON.stringify({ status: 'released', removed: before - data.locks.length }));
  process.exit(0);
}

if (action === 'list') {
  console.log(JSON.stringify(data, null, 2));
  process.exit(0);
}

console.error('Unknown action');
process.exit(2);
NODE
}

[[ $# -ge 1 ]] || { usage; exit 2; }
ACTION="$1"
shift

case "$ACTION" in
  acquire|release)
    require_nonempty_file "$LOCK_FILE"
    acquire_fs_lock
    trap release_fs_lock EXIT
    run_node_lock_update "$ACTION" "$@"
    ;;
  list)
    require_nonempty_file "$LOCK_FILE"
    run_node_lock_update list
    ;;
  -h|--help)
    usage
    ;;
  *)
    fail "Unknown action: $ACTION"
    ;;
esac
