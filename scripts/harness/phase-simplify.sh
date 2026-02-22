#!/usr/bin/env bash
set -euo pipefail

source "$(dirname "$0")/common.sh"
to_root

./scripts/lint.sh
./scripts/typecheck.sh
./scripts/unit-test.sh

info "phase-simplify completed"
