#!/usr/bin/env bash

# SPDX-FileCopyrightText: 2026 Digg - Agency for digital government
#
# SPDX-License-Identifier: EUPL-1.2

set -e

if git diff --name-only ORIG_HEAD HEAD | grep -q "^project\.yml$"; then
    echo "==> project.yml changed — regenerating Xcode project..."
    xcodegen generate
fi
