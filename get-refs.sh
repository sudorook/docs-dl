#!/bin/bash
set -eu
source globals
source data

! check_command wget grep sed && exit 3

OUTPUT_DIR=output

function parse_version {
  grep "[0-9]\+\(\.[0-9]\+\)\?\(\.[0-9]\+\)\?" | \
    sed -n "s/^\([^0-9]*\s\?v\?n\?\)\?\([0-9]\+\)\(\.[0-9]\+\)\?\(\.[0-9]\+\)\?.*/\2\3\4/p" | \
    head -n 1
}

function download_wrapper {
  local bin="${1}"
  local cmd
  local version
  local url
  local urls
  local idx

  if ! [[ -v CMD[${bin}] ]]; then
    show_warning "${bin@Q} not supported. Skipping."
    return
  fi
  cmd="${CMD[${bin}]}"

  IFS='.' read -r -a version <<< "$(eval "${cmd}" 2>/dev/null | parse_version)"
  if [ "${#version[@]}" -eq 0 ]; then
    show_warning "${bin@Q} not installed. Skipping."
    return
  fi

  IFS=' ' read -r -a urls <<< "${URL[${bin}]}"
  for idx in "${!urls[@]}"; do
    url="${urls[$idx]}"
    if [ "${#version[@]}" -eq 3 ]; then
      url="${url//MAJOR/${version[0]}}"
      url="${url//MINOR/${version[1]}}"
      url="${url//PATCH/${version[2]}}"
    elif [ "${#version[@]}" -eq 2 ]; then
      url="${url//MAJOR/${version[0]}}"
      url="${url//MINOR/${version[1]}}"
    elif [ "${#version[@]}" -eq 1 ]; then
      url="${url//MAJOR/${version[0]}}"
    fi
    if [[ ${url:${#url}-1:1} = "/" ]]; then
      IFS="."
      wget --quiet --show-progress -O "${bin}-${version[*]}-${idx}.pdf" "${url}"
    else
      wget --quiet --show-progress -nc "${url}"
    fi
  done
}


#
# Main
#

if [ "$0" = "${BASH_SOURCE[0]}" ]; then
  mkdir -p "${OUTPUT_DIR}"
  pushd "${OUTPUT_DIR}" >/dev/null
  for KEY in "${!URL[@]}"; do
    download_wrapper "${KEY}"
  done
  popd >/dev/null
fi
