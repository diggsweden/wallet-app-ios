#!/usr/bin/env bash

# SPDX-FileCopyrightText: 2026 Digg - Agency for digital government
#
# SPDX-License-Identifier: EUPL-1.2

set -e

repo_root=$(git rev-parse --show-toplevel)
hooks_dir="$repo_root/.git/hooks"

echo "==> Installing pre-push hook..."
ln -sf "$repo_root/scripts/hooks/pre-push.sh" "$hooks_dir/pre-push"
chmod +x "$hooks_dir/pre-push"
echo "✓ pre-push hook installed at $hooks_dir/pre-push"

echo "==> Installing post-merge hook..."
ln -sf "$repo_root/scripts/hooks/post-merge.sh" "$hooks_dir/post-merge"
chmod +x "$hooks_dir/post-merge"
echo "✓ post-merge hook installed at $hooks_dir/post-merge"

echo "==> Installing post-checkout hook..."
ln -sf "$repo_root/scripts/hooks/post-checkout.sh" "$hooks_dir/post-checkout"
chmod +x "$hooks_dir/post-checkout"
echo "✓ post-checkout hook installed at $hooks_dir/post-checkout"
