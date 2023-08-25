#! /bin/bash
set -eu
source globals
source data

! check_command wget grep sed && exit 3

function try_wget {
  wget -q --tries=5 --timeout=30 --spider "${1}" > /dev/null
}

function test_url {
  local version
  local url
  local urls
  local tmp
  local key="${1}"
  local is_good=true

  IFS='.' read -r -a version <<< "${TEST["${key}"]}"
  IFS=' ' read -r -a urls <<< "${URL["${key}"]}"
  for tmp in "${urls[@]}"; do
    url="${tmp}"
    if [ "${#version[@]}" -eq 3 ]; then
      url="${url//MAJOR/${version[0]}}"
      url="${url//MINOR/${version[1]}}"
      url="${url//PATCH/${version[2]}}"
    elif [ "${#version[@]}" -eq 2 ]; then
      url="${url//MAJOR/${version[0]}}"
      url="${url//MINOR/${version[1]}}"
      url="${url//.PATCH/}"
    elif [ "${#version[@]}" -eq 1 ]; then
      url="${url//MAJOR/${version[0]}}"
      url="${url//.MINOR/}"
      url="${url//.PATCH/}"
    fi
    if try_wget "${url}"; then
      show_success "${key}: ${url}"
    else
      show_error "${key}: ${url}"
      is_good=false
    fi
  done

  "${is_good}" && return || return 1
}

if [ "${0}" = "${BASH_SOURCE[0]}" ]; then
  ALL_GOOD=true
  if [ "${#}" -eq 0 ]; then
    for KEY in "${!TEST[@]}"; do
      if ! test_url "${KEY}"; then
        ALL_GOOD=false
      fi
    done
  else
    for KEY in "${@}"; do
      if [ -n "${CMD[${KEY}]-}" ]; then
        if ! test_url "${KEY}"; then
          ALL_GOOD=false
        fi
      else
        show_error "ERROR: ${KEY@Q} not found."
      fi
    done
  fi
  "${ALL_GOOD}" && exit 0 || exit 1
fi
