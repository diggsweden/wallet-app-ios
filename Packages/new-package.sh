#!/usr/bin/env bash
# SPDX-FileCopyrightText: 2026 Digg - Agency for digital government
#
# SPDX-License-Identifier: EUPL-1.2

set -euo pipefail

if [[ $# -ne 1 ]]; then
  echo "Usage: $0 <PackageName>" >&2
  exit 1
fi

NAME="$1"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
PACKAGES_DIR="$REPO_ROOT/Packages"
PACKAGE_DIR="$PACKAGES_DIR/$NAME"
PROJECT_YML="$REPO_ROOT/project.yml"

if [[ -e "$PACKAGE_DIR" ]]; then
  echo "Error: $PACKAGE_DIR already exists." >&2
  exit 1
fi

echo "Creating package directory: $PACKAGE_DIR"
mkdir -p "$PACKAGE_DIR"

echo "Initialising Swift package '$NAME'..."
(cd "$PACKAGE_DIR" && swift package init --name "$NAME" --type library)

echo "Patching project.yml..."
python3 - "$PROJECT_YML" "$NAME" <<'PYEOF'
import sys, re

project_yml, name = sys.argv[1], sys.argv[2]
path = f"Packages/{name}"

with open(project_yml) as f:
    text = f.read()

# --- 1. Insert package entry before the `targets:` key ---
package_entry = f"  {name}:\n    path: {path}\n"
if re.search(rf"^  {re.escape(name)}:", text, re.MULTILINE):
    print(f"Package '{name}' already present in packages — skipping.", file=sys.stderr)
else:
    text = re.sub(r'^(targets:)', package_entry + r'\1', text, count=1, flags=re.MULTILINE)

# --- 2. Insert dependency entry before `preBuildScripts:` under WalletDemo ---
dep_entry = f"      - package: {name}\n        product: {name}\n"
if re.search(rf"^\s+- package: {re.escape(name)}$", text, re.MULTILINE):
    print(f"Dependency '{name}' already present — skipping.", file=sys.stderr)
else:
    text = re.sub(r'^(\s+preBuildScripts:)', dep_entry + r'\1', text, count=1, flags=re.MULTILINE)

with open(project_yml, "w") as f:
    f.write(text)

print("project.yml updated.")
PYEOF

echo "Running xcodegen..."
cd "$REPO_ROOT" && xcodegen generate

echo "Done."
