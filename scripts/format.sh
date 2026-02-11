#!/usr/bin/env bash

# SPDX-FileCopyrightText: 2026 Digg - Agency for digital government
#
# SPDX-License-Identifier: EUPL-1.2

set -e

if ! command -v swift-format &>/dev/null; then
  echo "Swift-format not found! Aborting."
  exit 2
fi

if [[ -n "$1" ]]; then
  files=("$1")
else
  readarray -t files < <(git ls-files '*.swift')
fi

echo "==> Formatting..."
swift-format -i "${files[@]}"

echo "==> Verifying changes..."
if ! output=$(./scripts/lint.sh 2>&1); then
  echo "❌ Could not auto-format the following files:"
  echo -e "\033[31m$output\033[0m"
  exit 1
fi

echo "✅ Done!"
exit 0
