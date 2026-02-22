#!/usr/bin/env bash
set -euo pipefail

source "$(dirname "$0")/common.sh"
to_root

INSTALL_DEPS="false"
MODE="bootstrap"

usage() {
  cat <<'USAGE'
Usage: ./scripts/harness/provision-env.sh [--install-deps true|false] [--mode bootstrap|local]
USAGE
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --install-deps)
      INSTALL_DEPS="$2"
      shift 2
      ;;
    --install-deps=*)
      INSTALL_DEPS="${1#*=}"
      shift
      ;;
    --mode)
      MODE="$2"
      shift 2
      ;;
    --mode=*)
      MODE="${1#*=}"
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

case "$INSTALL_DEPS" in
  true|false) ;;
  *) fail "--install-deps must be true|false" ;;
esac

case "$MODE" in
  bootstrap|local) ;;
  *) fail "--mode must be bootstrap|local" ;;
esac

mkdir -p .devcontainer .planning/gaps docs/_meta scripts/harness tests/unit src

if [[ ! -f .devcontainer/devcontainer.json ]]; then
  cat > .devcontainer/devcontainer.json <<'JSON'
{
  "name": "agent-harness",
  "image": "mcr.microsoft.com/devcontainers/javascript-node:22",
  "postCreateCommand": "./scripts/harness/verify-env.sh"
}
JSON
fi

if [[ ! -f .nvmrc ]]; then
  cat > .nvmrc <<'NVM'
22
NVM
fi

if [[ ! -f .npmrc ]]; then
  cat > .npmrc <<'NPMRC'
save-exact=true
fund=false
audit=false
NPMRC
fi

if [[ "$INSTALL_DEPS" == "true" ]]; then
  require_cmd npm
  if [[ -f package.json ]]; then
    if [[ -f package-lock.json ]]; then
      npm ci
    else
      npm install --package-lock-only
      npm ci
    fi
  fi
fi

info "provision-env completed (mode=$MODE, install_deps=$INSTALL_DEPS)"
