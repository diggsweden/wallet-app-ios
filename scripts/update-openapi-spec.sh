#!/usr/bin/env bash

# SPDX-FileCopyrightText: 2026 Digg - Agency for digital government
#
# SPDX-License-Identifier: EUPL-1.2

# Fetches the latest Wallet Client Gateway OpenAPI spec from the sandbox
# and writes it to the WalletGateway package.

set -euo pipefail

SPEC_URL="${SPEC_URL:-https://wallet.sandbox.digg.se/api/wallet-client-gateway-openapi-v0.yaml}"
SPEC_PATH="Packages/WalletGatewayApi/WalletGateway/Sources/WalletGateway/OpenAPI/openapi.yaml"

cd "$(dirname "$0")/.."

spec_version() {
  sed -n 's/^  version: *//p' "$1" | head -1
}

tmp="$(mktemp -t openapi.XXXXXX)"
trap 'rm -f "$tmp"' EXIT

printf "==> Fetching %s\n" "$SPEC_URL"
curl --fail --silent --show-error --location --max-time 30 "$SPEC_URL" -o "$tmp"

if ! grep -q '^openapi:' "$tmp"; then
  printf "Error: response is not an OpenAPI document\n" >&2
  exit 1
fi

old_version="$(spec_version "$SPEC_PATH" 2>/dev/null || echo "none")"
new_version="$(spec_version "$tmp")"

if [[ -f "$SPEC_PATH" ]] && cmp -s "$tmp" "$SPEC_PATH"; then
  printf "==> Already up to date (version %s)\n" "$new_version"
  exit 0
fi

mv "$tmp" "$SPEC_PATH"
trap - EXIT

printf "==> Updated %s (%s -> %s)\n" "$SPEC_PATH" "$old_version" "$new_version"
printf "==> Rebuild to regenerate the client: just build\n"
