#!/usr/bin/env bash
set -e

echo "==> Checking Swift formatting before push..."
if ! ./scripts/lint.sh; then
  echo
  echo "❌  Push blocked: formatting issues found! Please run: ./scripts/format.sh"
  exit 1
fi
