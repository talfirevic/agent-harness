#!/usr/bin/env bash
set -euo pipefail

source "$(dirname "$0")/common.sh"
to_root

require_nonempty_file package.json
require_nonempty_file tsconfig.json
require_nonempty_file eslint.config.mjs
require_nonempty_file .prettierrc.json
require_nonempty_file vitest.config.ts

require_contains package.json '"typescript": "5.6.3"'
require_contains package.json '"eslint": "9.17.0"'
require_contains package.json '"prettier": "3.4.2"'
require_contains package.json '"vitest": "2.1.8"'

info "check-toolchain-baseline passed"
