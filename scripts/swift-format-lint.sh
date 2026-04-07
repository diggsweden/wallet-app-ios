#!/usr/bin/env bash

# SPDX-FileCopyrightText: 2026 Digg - Agency for digital government
#
# SPDX-License-Identifier: EUPL-1.2

set -e

if ! command -v swift-format &>/dev/null; then
  echo "Swift-format not found! Aborting."
  exit 2
fi

swift-format lint --strict --recursive --parallel Wallet WalletTests WalletUITests WalletMacros
