#!/usr/bin/env bash

# SPDX-FileCopyrightText: 2026 Digg - Agency for digital government
#
# SPDX-License-Identifier: EUPL-1.2

# Copies all *.example files in Configurations/ to their non-example counterparts.
# Skips files that already exist.

set -euo pipefail

for example in Configurations/*.example; do
  dest="${example%.example}"
  if [[ ! -f "$dest" ]]; then
    cp "$example" "$dest"
    printf "Created %s\n" "$(basename "$dest")"
  fi
done
