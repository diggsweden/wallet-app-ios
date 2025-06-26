#!/usr/bin/env bash
set -e

readarray -t files < <(git diff --cached --name-only --diff-filter=ACM | grep '\.swift$' || true)
if [[ ${#files[@]} -eq 0 ]]; then
  exit 0
fi

repo_root=$(git rev-parse --show-toplevel)

for file in "${files[@]}"; do
  "$repo_root/scripts/format.sh" "$file"
done
git add "${files[@]}"
