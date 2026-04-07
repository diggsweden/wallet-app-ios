#!/usr/bin/env bash

# SPDX-FileCopyrightText: 2026 Digg - Agency for digital government
#
# SPDX-License-Identifier: EUPL-1.2

failed=0
./scripts/swift-format-lint.sh || failed=1
./scripts/swiftlint.sh || failed=1

if [[ "$failed" -ne 0 ]]; then
  echo
  echo "Push blocked: lint issues found. Run: just fix"
  exit 1
fi
