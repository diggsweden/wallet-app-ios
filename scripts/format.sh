#!/usr/bin/env bash
set -e

if ! command -v swift-format &>/dev/null; then
  echo "Swift-format not found! Aborting."
  exit 2
fi

files=${1:-$(git ls-files '*.swift')}

echo "==> Formatting..."
swift-format -i $files

echo "==> Verifying changes..."
if ! output=$(./scripts/lint.sh "$files" 2>&1); then
  echo "❌ Could not auto-format the following files:"
  echo "$output"
  exit 1
fi

echo "✅ Done!"
exit 0
