#!/usr/bin/env bash

# SPDX-FileCopyrightText: 2026 Digg - Agency for digital government
#
# SPDX-License-Identifier: EUPL-1.2

set -e

echo "==> Checking Swift formatting before push..."
if ! ./scripts/lint.sh; then
  echo
  echo "❌  Push blocked: formatting issues found! Please run: ./scripts/format.sh"
  exit 1
fi
