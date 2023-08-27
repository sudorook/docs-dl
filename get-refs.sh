#! /bin/bash
set -euo pipefail

ROOT="$(dirname "${0}")"

source "${ROOT}"/data
source "${ROOT}"/globals

! check_command wget grep sed && exit 3

OUTPUT_DIR=output

mkdir -p "${OUTPUT_DIR}"
pushd "${OUTPUT_DIR}" > /dev/null
if [ "${#}" -eq 0 ]; then
  for KEY in "${!URL[@]}"; do
    download_wrapper "${KEY}"
  done
else
  for KEY in "${@}"; do
    if [ -n "${URL[${KEY}]-}" ]; then
      download_wrapper "${KEY}"
    else
      show_error "ERROR: ${KEY@Q} not found."
    fi
  done
fi
popd > /dev/null
