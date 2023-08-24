#!/bin/bash
set -euo pipefail
source globals
source data

! check_command wget grep sed && exit 3

OUTPUT_DIR=output

function parse_version {
  grep "[0-9]\+\(\.[0-9]\+\)\?\(\.[0-9]\+\)\?" |
    sed -n "s/^\([^0-9]*\s\?v\?n\?\)\?\([0-9]\+\)\(\.[0-9]\+\)\?\(\.[0-9]\+\)\?.*/\2\3\4/p" |
    head -n 1
}

function download_wrapper {
  local bin="${1}"
  local cmd
  local version
  local _version
  local url
  local urls
  local idx

  if ! [[ -v CMD[${bin}] ]]; then
    show_warning "${bin@Q} not supported. Skipping."
    return
  fi
  cmd="${CMD[${bin}]}"

  IFS='.' read -r -a version <<< "$(eval "${cmd}" 2> /dev/null | parse_version)"
  if [ "${#version[@]}" -eq 0 ]; then
    show_warning "${bin@Q} not installed. Skipping."
    return
  fi

  IFS=' ' read -r -a urls <<< "${URL["${bin}"]}"
  for idx in "${!urls[@]}"; do
    url="${urls["${idx}"]}"
    if [ "${#version[@]}" -eq 3 ]; then
      _version="${version[0]}.${version[1]}.${version[2]}"
      url="${url//MAJOR/${version[0]}}"
      url="${url//MINOR/${version[1]}}"
      url="${url//PATCH/${version[2]}}"
    elif [ "${#version[@]}" -eq 2 ]; then
      _version="${version[0]}.${version[1]}"
      url="${url//MAJOR/${version[0]}}"
      url="${url//MINOR/${version[1]}}"
      url="${url//.PATCH/}"
    elif [ "${#version[@]}" -eq 1 ]; then
      _version="${version[0]}"
      url="${url//MAJOR/${version[0]}}"
      url="${url//.MINOR/}"
      url="${url//.PATCH/}"
    fi
    if ! [[ "${url}" =~ ${_version} ]]; then
      if [[ "${url}" =~ /latest/ ]]; then
        _version="latest"
      elif [[ "${url}" =~ /stable/ ]]; then
        _version="stable"
      else
        _version="unknown"
      fi
    fi
    if [[ ${url:${#url}-1:1} = "/" ]]; then
      IFS="."
      if [[ "${url:${#url}-4:4}" = "pdf/" ]]; then
        if [ "${#urls[@]}" -gt 1 ]; then
          wget --quiet --show-progress -O "${bin}-${_version[*]}-${idx}.pdf" "${url}"
        else
          wget --quiet --show-progress -O "${bin}-${_version[*]}.pdf" "${url}"
        fi
      elif [[ "${url:${#url}-8:8}" = "htmlzip/" ]]; then
        if [ "${#urls[@]}" -gt 1 ]; then
          wget --quiet --show-progress -O "${bin}-${_version[*]}-${idx}.zip" "${url}"
        else
          wget --quiet --show-progress -O "${bin}-${_version[*]}.zip" "${url}"
        fi
      fi
    else
      wget --quiet --show-progress -nc "${url}"
    fi
  done
}

#
# Main
#

if [ "${0}" = "${BASH_SOURCE[0]}" ]; then
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
fi
