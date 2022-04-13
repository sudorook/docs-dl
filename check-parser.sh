#! /bin/bash
set -euo pipefail
source globals
source data
source ./get-refs.sh

function test_parser {
  local version
  local key
  local all_good=true
  local cmd

  for key in "${!CMD[@]}"; do
    cmd="${CMD[${key}]}"
    if version="$(eval "${cmd}" 2>/dev/null | parse_version)"; then
      if ! [[ "${version}" =~ ^[0-9]+(\.[0-9]+)?(\.[0-9]+)?$ ]]; then
        all_good=false
        show_error "✗ ${key}"
      else
        show_success "✓ ${key}"
      fi
    fi
  done

  ${all_good} && return 0 || return 1
}

test_parser
