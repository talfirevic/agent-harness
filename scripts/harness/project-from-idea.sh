#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
SOURCE_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

usage() {
  cat <<'EOF'
Usage:
  ./scripts/harness/project-from-idea.sh --idea "<one sentence idea>" [options]

Required:
  --idea TEXT                   Product idea to scaffold from.

Optional:
  --project-name NAME           Project slug. Defaults to slugified idea.
  --output-dir PATH             Target directory. Defaults to "./<project-name>".
  --stack NAME                  Stack choice. Defaults from template.
  --deployment-target NAME      Deployment target. Defaults from template.
  --compliance-profile NAME     Compliance profile. Default: standard-web.
  --build-now true|false        Run make verify after scaffolding. Default: true.
  --init-git true|false         Initialize git repo if missing. Default: true.
  --force                       Allow writing into non-empty output dir.
  -h, --help                    Show this help.

Examples:
  ./scripts/harness/project-from-idea.sh --idea "B2B inventory platform"
  ./scripts/harness/project-from-idea.sh \
    --idea "Team analytics dashboard" \
    --project-name team-analytics \
    --output-dir /tmp/team-analytics \
    --stack typescript-node \
    --deployment-target vercel \
    --build-now false
EOF
}

info() {
  echo "[project-from-idea] $*"
}

fail() {
  echo "ERROR: $*" >&2
  exit 1
}

require_cmd() {
  local cmd="$1"
  command -v "$cmd" >/dev/null 2>&1 || fail "Required command not found: $cmd"
}

slugify() {
  local input="$1"
  local slug

  slug="$(printf '%s' "$input" \
    | tr '[:upper:]' '[:lower:]' \
    | sed -E 's/[^a-z0-9]+/-/g; s/^-+//; s/-+$//; s/-+/-/g')"

  if [[ -z "$slug" ]]; then
    slug="agent-project"
  fi

  printf '%s\n' "$slug"
}

read_yaml_scalar() {
  local file="$1"
  local key="$2"
  local value

  [[ -f "$file" ]] || fail "Missing template file: $file"
  value="$(sed -n "s/^${key}:[[:space:]]*//p" "$file" | head -n 1 | tr -d '\r')"
  [[ -n "$value" ]] || fail "Missing key '${key}' in template: $file"
  printf '%s\n' "$value"
}

normalize_bool() {
  local value="$1"
  case "$value" in
    true|false)
      printf '%s\n' "$value"
      ;;
    *)
      fail "Expected boolean true|false, got: $value"
      ;;
  esac
}

write_file() {
  local path="$1"
  local content="$2"
  mkdir -p "$(dirname "$path")"
  printf '%s' "$content" > "$path"
}

copy_baseline_item() {
  local rel="$1"
  local src="$SOURCE_ROOT/$rel"
  local dest="$OUTPUT_DIR/$rel"

  [[ -e "$src" ]] || fail "Missing baseline item in source repo: $rel"

  if [[ -d "$src" ]]; then
    mkdir -p "$dest"
    cp -R "$src"/. "$dest"
  else
    mkdir -p "$(dirname "$dest")"
    cp "$src" "$dest"
  fi
}

ensure_required_dirs() {
  mkdir -p \
    "$OUTPUT_DIR/.claude/hooks" \
    "$OUTPUT_DIR/.claude/agents" \
    "$OUTPUT_DIR/.claude/skills" \
    "$OUTPUT_DIR/.planning/phases/phase-1" \
    "$OUTPUT_DIR/.planning/tasks" \
    "$OUTPUT_DIR/.planning/locks" \
    "$OUTPUT_DIR/.github/workflows" \
    "$OUTPUT_DIR/docs/architecture" \
    "$OUTPUT_DIR/docs/design" \
    "$OUTPUT_DIR/docs/quality" \
    "$OUTPUT_DIR/docs/ops" \
    "$OUTPUT_DIR/docs/runbooks" \
    "$OUTPUT_DIR/scripts/harness" \
    "$OUTPUT_DIR/tests/structural"
}

IDEA=""
PROJECT_NAME=""
OUTPUT_DIR=""
STACK=""
DEPLOYMENT_TARGET=""
COMPLIANCE_PROFILE=""
BUILD_NOW="true"
INIT_GIT="true"
FORCE="false"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --idea)
      [[ $# -ge 2 ]] || fail "Missing value for --idea"
      IDEA="$2"
      shift 2
      ;;
    --idea=*)
      IDEA="${1#*=}"
      shift
      ;;
    --project-name)
      [[ $# -ge 2 ]] || fail "Missing value for --project-name"
      PROJECT_NAME="$2"
      shift 2
      ;;
    --project-name=*)
      PROJECT_NAME="${1#*=}"
      shift
      ;;
    --output-dir)
      [[ $# -ge 2 ]] || fail "Missing value for --output-dir"
      OUTPUT_DIR="$2"
      shift 2
      ;;
    --output-dir=*)
      OUTPUT_DIR="${1#*=}"
      shift
      ;;
    --stack)
      [[ $# -ge 2 ]] || fail "Missing value for --stack"
      STACK="$2"
      shift 2
      ;;
    --stack=*)
      STACK="${1#*=}"
      shift
      ;;
    --deployment-target)
      [[ $# -ge 2 ]] || fail "Missing value for --deployment-target"
      DEPLOYMENT_TARGET="$2"
      shift 2
      ;;
    --deployment-target=*)
      DEPLOYMENT_TARGET="${1#*=}"
      shift
      ;;
    --compliance-profile)
      [[ $# -ge 2 ]] || fail "Missing value for --compliance-profile"
      COMPLIANCE_PROFILE="$2"
      shift 2
      ;;
    --compliance-profile=*)
      COMPLIANCE_PROFILE="${1#*=}"
      shift
      ;;
    --build-now)
      [[ $# -ge 2 ]] || fail "Missing value for --build-now"
      BUILD_NOW="$2"
      shift 2
      ;;
    --build-now=*)
      BUILD_NOW="${1#*=}"
      shift
      ;;
    --init-git)
      [[ $# -ge 2 ]] || fail "Missing value for --init-git"
      INIT_GIT="$2"
      shift 2
      ;;
    --init-git=*)
      INIT_GIT="${1#*=}"
      shift
      ;;
    --force)
      FORCE="true"
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

[[ -n "$IDEA" ]] || fail "--idea is required"

BUILD_NOW="$(normalize_bool "$BUILD_NOW")"
INIT_GIT="$(normalize_bool "$INIT_GIT")"

STACK_DEFAULT_FILE="$SOURCE_ROOT/.claude/skills/project-from-idea/templates/stack-defaults.yml"
DEPLOY_DEFAULT_FILE="$SOURCE_ROOT/.claude/skills/project-from-idea/templates/deploy-defaults.yml"

DEFAULT_STACK="$(read_yaml_scalar "$STACK_DEFAULT_FILE" "default_stack")"
DEFAULT_DEPLOY_TARGET="$(read_yaml_scalar "$DEPLOY_DEFAULT_FILE" "default_deployment_target")"

STACK_DEFAULTED="false"
DEPLOYMENT_DEFAULTED="false"
COMPLIANCE_DEFAULTED="false"

if [[ -z "$STACK" ]]; then
  STACK="$DEFAULT_STACK"
  STACK_DEFAULTED="true"
fi

if [[ -z "$DEPLOYMENT_TARGET" ]]; then
  DEPLOYMENT_TARGET="$DEFAULT_DEPLOY_TARGET"
  DEPLOYMENT_DEFAULTED="true"
fi

if [[ -z "$COMPLIANCE_PROFILE" ]]; then
  COMPLIANCE_PROFILE="standard-web"
  COMPLIANCE_DEFAULTED="true"
fi

if [[ -z "$PROJECT_NAME" ]]; then
  PROJECT_NAME="$(slugify "$IDEA")"
fi

PROJECT_NAME="$(slugify "$PROJECT_NAME")"

if [[ -z "$OUTPUT_DIR" ]]; then
  OUTPUT_DIR="./$PROJECT_NAME"
fi

output_parent="$(dirname "$OUTPUT_DIR")"
mkdir -p "$output_parent"
OUTPUT_DIR="$(cd "$output_parent" && pwd)/$(basename "$OUTPUT_DIR")"

if [[ -d "$OUTPUT_DIR" ]]; then
  if [[ -n "$(find "$OUTPUT_DIR" -mindepth 1 -maxdepth 1 -print -quit)" && "$FORCE" != "true" ]]; then
    fail "Output dir is not empty: $OUTPUT_DIR (use --force to allow overwrite)"
  fi
else
  mkdir -p "$OUTPUT_DIR"
fi

require_cmd cp
require_cmd mkdir
require_cmd sed

if [[ "$OUTPUT_DIR" != "$SOURCE_ROOT" ]]; then
  info "Copying harness baseline to $OUTPUT_DIR"
  for item in \
    .claude \
    .github \
    .planning \
    docs \
    scripts \
    src \
    tests \
    package.json \
    tsconfig.json \
    eslint.config.mjs \
    .prettierrc.json \
    vitest.config.ts \
    Makefile \
    AGENTS.md \
    HARNESS_PRINCIPLES.md \
    paybook.md
  do
    copy_baseline_item "$item"
  done
fi

(cd "$OUTPUT_DIR" && ./scripts/harness/scaffold-harness.sh)
(cd "$OUTPUT_DIR" && ./scripts/harness/provision-env.sh --mode bootstrap --install-deps false)
(cd "$OUTPUT_DIR" && ./scripts/harness/verify-env.sh)

today="$(date +%F)"
human_name="$(printf '%s' "$PROJECT_NAME" | tr '-' ' ')"

project_md_content="# PROJECT

## Name
$PROJECT_NAME

## Problem
$IDEA

## Users
- Primary users are teams solving the above problem.
- Secondary users are operators and administrators of the product.

## MVP Scope
- Deliver a usable first version focused on the core workflow.
- Keep implementation aligned with harness enforcement and autonomous delivery.

## Constraints
- Stack: \`$STACK\`
- Deployment target: \`$DEPLOYMENT_TARGET\`
- Compliance profile: \`$COMPLIANCE_PROFILE\`

## Non-Goals
- Full platform expansion beyond MVP.
- Manual, ad-hoc development flow outside harness checks.

## Success Metrics
- One-command scaffold from idea succeeds.
- Required harness checks remain green on main.
- Autonomous phase execution can deliver REQ-linked increments.

## Metadata
- Created: $today
- Seeded by: scripts/harness/project-from-idea.sh
"

requirements_md_content="# REQUIREMENTS

| ID | Requirement | Acceptance Criteria | Status |
|---|---|---|---|
| REQ-001 | Create MVP foundation for \"$human_name\" | Core project artifacts and baseline docs are generated from a single command | active |
| REQ-002 | Automatic harness setup | Skills, agents, hooks, and checks are installed without manual setup steps | active |
| REQ-003 | Parallel-safe execution | Every task defines \`touches:\` and conflicts resolve through lock protocol | active |
| REQ-004 | Mechanical enforcement | CI runs readiness, principles, boundary, structure, docs, artifact-sync, and coverage checks | active |
| REQ-005 | Autonomous delivery lane | \`autonomous-build\` can run plan -> execute -> verify -> merge with no manual product coding | active |
"

assumptions_md_content="# ASSUMPTIONS

- Idea provided: \"$IDEA\"
- Stack: \`$STACK\` (defaulted: $STACK_DEFAULTED)
- Deployment target: \`$DEPLOYMENT_TARGET\` (defaulted: $DEPLOYMENT_DEFAULTED)
- Compliance profile: \`$COMPLIANCE_PROFILE\` (defaulted: $COMPLIANCE_DEFAULTED)
- build_now: \`$BUILD_NOW\`
- init_git: \`$INIT_GIT\`
"

roadmap_md_content="# ROADMAP

## Milestone M1: Bootstrap and enforce
Goal: Scaffold and validate an autonomous, agent-first harness baseline for \"$human_name\".

### Phase 1
- REQ-001: Generate project foundation from CLI input.
- REQ-002: Confirm automatic harness installation and readiness.
- REQ-004: Wire all required CI quality gates.

### Phase 2
- REQ-003: Harden parallel lock protocol and overlap resolution.
- REQ-005: Drive autonomous delivery workflow through phase verification.
"

state_md_content="# STATE

current_milestone: M1
current_phase: 1
last_verified_commit: pending

open_gaps:
- GAP-001: \"Initial scaffold generated; feature implementation not started.\"

blockers: []
"

plan_md_content="# Phase 1 PLAN

## Wave 1

### Task T1
- objective: Confirm scaffold and project contract for \"$human_name\".
- touches:
  - PROJECT.md
  - REQUIREMENTS.md
  - AGENTS.md
  - .planning/
- reads:
  - paybook.md
  - HARNESS_PRINCIPLES.md
- reqs:
  - REQ-001
  - REQ-002
- verification:
  - ./scripts/harness/readiness-check.sh

### Task T2
- objective: Validate mechanical gates.
- touches:
  - scripts/harness/
  - .github/workflows/
- reads:
  - docs/quality/INVARIANTS.md
- reqs:
  - REQ-004
- verification:
  - ./scripts/harness/check-all.sh

## Wave 2

### Task T3
- objective: Exercise autonomous lane with non-overlapping tasks.
- touches:
  - .claude/skills/
  - .claude/agents/
  - .planning/locks/LOCKS.json
- reads:
  - .planning/ROADMAP.md
- reqs:
  - REQ-003
  - REQ-005
- verification:
  - ./scripts/harness/check-lock-protocol.sh

## Progress
- Initial plan generated by project-from-idea runner.

## Decision Log
- Defaulted non-blocking input values to keep flow non-interactive.

## Surprises
- None.

## Outcomes
- Pending autonomous execution evidence.
"

verification_md_content="# Phase 1 VERIFICATION

Status: PENDING

This file is generated as a placeholder and must be updated after autonomous execution.

| REQ | Expected Evidence |
|---|---|
| REQ-001 | ./scripts/harness/readiness-check.sh |
| REQ-002 | readiness output confirms skills, agents, hooks, and checks |
| REQ-003 | ./scripts/harness/check-lock-protocol.sh |
| REQ-004 | ./scripts/harness/check-all.sh |
| REQ-005 | autonomous-build execution summary |
"

traceability_md_content="# Traceability

| REQ | Verification Command |
|---|---|
| REQ-001 | \`./scripts/harness/readiness-check.sh\` |
| REQ-002 | \`./scripts/harness/readiness-check.sh\` |
| REQ-003 | \`./scripts/harness/check-lock-protocol.sh\` |
| REQ-004 | \`./scripts/harness/check-all.sh\` |
| REQ-005 | \`./scripts/harness/check-no-manual-code-lane.sh\` |
"

readme_md_content="# $PROJECT_NAME

Generated on $today with:

\`\`\`bash
./scripts/harness/project-from-idea.sh --idea \"$IDEA\"
\`\`\`

## Selected Defaults
- stack: \`$STACK\`
- deployment target: \`$DEPLOYMENT_TARGET\`
- compliance profile: \`$COMPLIANCE_PROFILE\`

## First Commands
\`\`\`bash
./scripts/bootstrap --idea \"$IDEA\" --build-now true
make verify
\`\`\`

## Autonomous Lane
\`\`\`text
./scripts/harness/ship-phase.sh --phase 1 --parallel auto --dry-run true
\`\`\`
"

write_file "$OUTPUT_DIR/PROJECT.md" "$project_md_content"
write_file "$OUTPUT_DIR/REQUIREMENTS.md" "$requirements_md_content"
write_file "$OUTPUT_DIR/.planning/ASSUMPTIONS.md" "$assumptions_md_content"
write_file "$OUTPUT_DIR/.planning/ROADMAP.md" "$roadmap_md_content"
write_file "$OUTPUT_DIR/.planning/STATE.md" "$state_md_content"
write_file "$OUTPUT_DIR/.planning/phases/phase-1/PLAN.md" "$plan_md_content"
write_file "$OUTPUT_DIR/.planning/phases/phase-1/VERIFICATION.md" "$verification_md_content"
write_file "$OUTPUT_DIR/tests/TRACEABILITY.md" "$traceability_md_content"
write_file "$OUTPUT_DIR/README.md" "$readme_md_content"

if [[ ! -f "$OUTPUT_DIR/.planning/locks/LOCKS.json" ]]; then
  write_file "$OUTPUT_DIR/.planning/locks/LOCKS.json" "{\n  \"locks\": []\n}\n"
fi

if [[ "$INIT_GIT" == "true" && ! -d "$OUTPUT_DIR/.git" ]]; then
  if command -v git >/dev/null 2>&1; then
    info "Initializing git repository"
    (cd "$OUTPUT_DIR" && git init -q)
  else
    info "Skipping git init: git not found"
  fi
fi

if [[ "$INIT_GIT" == "true" && -d "$OUTPUT_DIR/.git" ]]; then
  if [[ -z "$(git -C "$OUTPUT_DIR" rev-list --max-count=1 HEAD 2>/dev/null || true)" ]]; then
    git -C "$OUTPUT_DIR" config user.name >/dev/null 2>&1 || git -C "$OUTPUT_DIR" config user.name "Harness Bootstrap"
    git -C "$OUTPUT_DIR" config user.email >/dev/null 2>&1 || git -C "$OUTPUT_DIR" config user.email "harness-bootstrap@local"
    (cd "$OUTPUT_DIR" && git add . && git commit -m "chore: bootstrap harness from idea" >/dev/null)
  fi
fi

if [[ "$BUILD_NOW" == "true" ]]; then
  info "Running readiness and full harness checks"
  (cd "$OUTPUT_DIR" && make verify)
fi

cat <<EOF
[project-from-idea] scaffold complete
path: $OUTPUT_DIR
project: $PROJECT_NAME
stack: $STACK
deployment_target: $DEPLOYMENT_TARGET
compliance_profile: $COMPLIANCE_PROFILE
build_now: $BUILD_NOW
init_git: $INIT_GIT

next:
  cd "$OUTPUT_DIR"
  make verify
  ./scripts/harness/ship-phase.sh --phase 1 --parallel auto --dry-run true
EOF
