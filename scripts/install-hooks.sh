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
echo "✅ pre-push hook installed at $hooks_dir/pre-push"

if [[ "$1" == "--format-on-commit" ]]; then
  echo "==> Installing optional pre-commit format hook..."
  ln -sf "$repo_root/scripts/format.sh" "$hooks_dir/pre-commit"
  chmod +x "$hooks_dir/pre-commit"
  echo "✅ pre-commit hook installed at $hooks_dir/pre-commit"
else
  echo "ℹ️ Skipped pre-commit hook. Use --format-on-commit to enable it."
fi
