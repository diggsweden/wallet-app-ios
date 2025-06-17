#!/usr/bin/env bash
set -e

files=$(git diff --cached --name-only --diff-filter=ACM | grep '\.swift$' || true)
if [[ -z "$files" ]]; then
  exit 0
fi

repo_root=$(git rev-parse --show-toplevel)

"$repo_root/scripts/format.sh $files"
git add "$files"
