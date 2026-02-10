#!/usr/bin/env bash

# SPDX-FileCopyrightText: 2026 diggsweden/wallet-app-ios
#
# SPDX-License-Identifier: EUPL-1.2

set -e

git ls-files -z -- '*.swift' '*.sh' |
  xargs -0 reuse annotate \
    --license EUPL-1.2 \
    --copyright "diggsweden/wallet-app-ios" \
    --year "$(date +%Y)" \
    --skip-unrecognised \
    --skip-existing
