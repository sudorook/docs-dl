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
  local tmp

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
  for tmp in "${urls[@]}"; do
    url="${tmp}"
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
    wget -nc "${url}"
  done
}


#
# Main
#

if [ "$0" = "${BASH_SOURCE[0]}" ]; then
  mkdir -p "${OUTPUT_DIR}"
  pushd "${OUTPUT_DIR}" >/dev/null
  download_wrapper "awk"
  download_wrapper "bash"
  download_wrapper "bc"
  download_wrapper "biopython"
  download_wrapper "ffmpeg"
  download_wrapper "fish"
  download_wrapper "gcc"
  download_wrapper "gimp"
  download_wrapper "inkscape"
  download_wrapper "julia"
  download_wrapper "lua"
  download_wrapper "matplotlib"
  download_wrapper "nodejs"
  download_wrapper "numpy"
  download_wrapper "octave"
  download_wrapper "pandas"
  download_wrapper "python"
  download_wrapper "r"
  download_wrapper "sed"
  download_wrapper "scipy"
  download_wrapper "sklearn"
  download_wrapper "zsh"
  popd >/dev/null
fi
