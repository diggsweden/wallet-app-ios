#!/usr/bin/env bash

# SPDX-FileCopyrightText: 2026 Digg - Agency for digital government
#
# SPDX-License-Identifier: EUPL-1.2

set -e

repo_root=$(git rev-parse --show-toplevel)
hooks_dir="$repo_root/.git/hooks"

mkdir -p "$hooks_dir"

install_hook() {
  local name="$1"
  local source="$repo_root/scripts/hooks/$name.sh"
  local target="$hooks_dir/$name"

  if [[ -L "$target" && "$(readlink "$target")" == "$source" ]]; then
    return
  fi

  echo "==> Installing $name hook..."
  ln -sf "$source" "$target"
  chmod +x "$target"
  echo "✓ $name hook installed"
}

install_hook pre-push
install_hook post-merge
install_hook post-checkout
install_hook pre-commit
