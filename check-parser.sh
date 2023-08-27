#! /bin/bash
set -euo pipefail

ROOT="$(dirname "${0}")"

source "${ROOT}"/data
source "${ROOT}"/globals

! check_command wget grep sed && exit 3

ALL_GOOD=true

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

"${ALL_GOOD}" && exit 0 || exit 1
