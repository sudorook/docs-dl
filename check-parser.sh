#! /bin/bash
set -euo pipefail
source globals
source data
source ./get-refs.sh

function test_parser {
  local version
  local key="${1}"
  local cmd

  cmd="${CMD["${key}"]}"
  if version="$(eval "${cmd}" 2> /dev/null | parse_version)"; then
    if ! [[ "${version}" =~ ^[0-9]+(\.[0-9]+)?(\.[0-9]+)?(\.[0-9]+)?(\.[0-9]+)?$ ]]; then
      show_error "✗ ${key}"
      return 1
    else
      show_success "✓ ${key}"
      return 0
    fi
  else
    if command -v "${key%% *}" > /dev/null; then
      show_error "✗ ${key}"
      return 1
    else
      show_warning "？${key}"
      return 0
    fi
  fi
}

ALL_GOOD=true

if [ "${0}" = "${BASH_SOURCE[0]}" ]; then
  if [ "${#}" -eq 0 ]; then
    for KEY in "${!CMD[@]}"; do
      if ! test_parser "${KEY}"; then
        ALL_GOOD=false
      fi
    done
  else
    for KEY in "${@}"; do
      if [ -n "${CMD[${KEY}]-}" ]; then
        if ! test_parser "${KEY}"; then
          ALL_GOOD=false
        fi
      else
        show_error "ERROR: ${KEY@Q} not found."
      fi
    done
  fi
fi

"${ALL_GOOD}" && exit 0 || exit 1
