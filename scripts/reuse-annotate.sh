#!/usr/bin/env bash

# SPDX-FileCopyrightText: 2026 Digg - Agency for digital government
#
# SPDX-License-Identifier: EUPL-1.2

set -e

git ls-files -z -- '*.swift' '*.sh' |
  xargs -0 reuse annotate \
    --license EUPL-1.2 \
    --copyright "Digg - Agency for digital government" \
    --year "$(date +%Y)" \
    --skip-unrecognised \
    --skip-existing
