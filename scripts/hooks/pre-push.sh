#!/usr/bin/env bash

# SPDX-FileCopyrightText: 2026 Digg - Agency for digital government
#
# SPDX-License-Identifier: EUPL-1.2

set -e

echo "==> Checking Swift formatting before push..."
if ! ./scripts/swift-format-lint.sh; then
  echo
  echo "❌  Push blocked: formatting issues found! Please run: ./scripts/format.sh"
  exit 1
fi

echo "==> Running SwiftLint before push..."
if ! ./scripts/swiftlint.sh; then
  echo
  echo "❌  Push blocked: SwiftLint violations found! Please fix them or run: just lint-swift-fix"
  exit 1
fi
