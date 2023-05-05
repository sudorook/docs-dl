#! /bin/bash
set -eu
source globals
source data

! check_command wget grep sed && exit 3

function try_wget {
  wget -q --tries=5 --timeout=30 --spider "${1}" >/dev/null
}

function test_urls {
  local version
  local url
  local urls
  local tmp
  local key
  local missing=false

  for key in "${!TEST[@]}"; do
    IFS='.' read -r -a version <<<"${TEST[$key]}"
    IFS=' ' read -r -a urls <<<"${URL[${key}]}"
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
      if try_wget "${url}"; then
        show_success "${key}: ${url}"
      else
        show_error "${key}: ${url}"
        missing=true
      fi
    done
  done

  ${missing} && return 1 || return 0
}

test_urls
