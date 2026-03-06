#!/usr/bin/env bash

# SPDX-FileCopyrightText: 2026 Digg - Agency for digital government
#
# SPDX-License-Identifier: EUPL-1.2

set -e

previous_head="$1"
new_head="$2"
is_branch_checkout="$3" # 1 = branch checkout, 0 = file checkout (e.g. git checkout -- file.swift)

# Only regenerate on branch switches, not individual file checkouts
if [ "$is_branch_checkout" != "1" ]; then
  exit 0
fi

if git diff --name-only "$previous_head" "$new_head" | grep -q "^project\.yml$"; then
  echo "==> project.yml changed — regenerating Xcode project..."
  xcodegen generate
fi
