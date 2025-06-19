#!/usr/bin/env bash
set -e

if ! command -v swift-format &>/dev/null; then
  echo "Swift-format not found! Aborting."
  exit 2
fi

files=${1:-$(git ls-files '*.swift')}

if [[ -z "$files" ]]; then
  exit 0
fi

swift-format lint -s "$files"
