#!/usr/bin/env bash

# SPDX-FileCopyrightText: 2026 Digg - Agency for digital government
#
# SPDX-License-Identifier: EUPL-1.2

set -e

if ! command -v swift-format &>/dev/null; then
  echo "Swift-format not found! Aborting."
  exit 2
fi

swift-format format --in-place --recursive --parallel Wallet WalletTests WalletUITests WalletMacros

if ! output=$(./scripts/swift-format-lint.sh 2>&1); then
  echo "Could not auto-format the following files:"
  echo "$output"
  exit 1
fi
