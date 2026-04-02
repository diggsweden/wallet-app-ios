#!/usr/bin/env bash

# SPDX-FileCopyrightText: 2026 Digg - Agency for digital government
#
# SPDX-License-Identifier: EUPL-1.2

set -e

export PATH="$HOME/.local/share/mise/shims:/opt/homebrew/bin:$PATH"

if ! command -v swiftlint &>/dev/null; then
  echo "SwiftLint not found! Run: mise install"
  exit 2
fi

swiftlint lint --strict --quiet
