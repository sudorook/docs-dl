#!/bin/bash

# SPDX-FileCopyrightText: 2022 - 2024 sudorook <daemon@nullcodon.com>
#
# SPDX-License-Identifier: GPL-3.0-or-later
#
# This program is free software: you can redistribute it and/or modify it
# under the terms of the GNU General Public License as published by the Free
# Software Foundation, either version 3 of the License, or (at your option)
# any later version.
#
# This program is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
# or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License
# for more details.
#
# You should have received a copy of the GNU General Public License along
# with this program. If not, see <https://www.gnu.org/licenses/>.

set -euo pipefail

ROOT="$(dirname "${0}")"

source "${ROOT}"/data
source "${ROOT}"/globals

! check_command grep sed && exit 3

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
