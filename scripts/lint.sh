#!/usr/bin/env bash
set -e

if ! command -v swift-format &>/dev/null; then
  echo "Swift-format not found! Aborting."
  exit 2
fi

if [[ -n "$1" ]]; then
  files=("$1")
else
  readarray -t files < <(git ls-files '*.swift')
fi

if [[ ${#files[@]} -eq 0 ]]; then
  exit 0
fi

swift-format lint -s "${files[@]}"
