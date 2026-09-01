#!/usr/bin/env bash

# SPDX-FileCopyrightText: 2026 Digg - Agency for digital government
#
# SPDX-License-Identifier: EUPL-1.2

set -euo pipefail

if [[ $# -ne 1 ]]; then
  echo "usage: $0 <PackageName>" >&2
  exit 1
fi

name="$1"

if [[ ! "$name" =~ ^[A-Z][A-Za-z0-9]*$ ]]; then
  echo "error: package name must be UpperCamelCase alphanumeric" >&2
  exit 1
fi

root="$(cd "$(dirname "$0")/.." && pwd)"
pkg_dir="$root/Packages/$name"

if [[ -e "$pkg_dir" ]]; then
  echo "error: $pkg_dir already exists" >&2
  exit 1
fi

mkdir -p "$pkg_dir/Sources/$name" "$pkg_dir/Tests/${name}Tests"

cat > "$pkg_dir/Package.swift" <<EOF
// SPDX-FileCopyrightText: 2026 Digg - Agency for digital government
//
// SPDX-License-Identifier: EUPL-1.2

// swift-tools-version: 6.3

import PackageDescription

let package = Package(
  name: "$name",
  platforms: [
    .iOS(.v17)
  ],
  products: [
    .library(
      name: "$name",
      targets: ["$name"],
    )
  ],
  targets: [
    .target(
      name: "$name"
    ),
    .testTarget(
      name: "${name}Tests",
      dependencies: ["$name"],
    ),
  ],
  swiftLanguageModes: [.v6],
)
EOF

cat > "$pkg_dir/.gitignore" <<'EOF'
.DS_Store
/.build
/Packages
xcuserdata/
DerivedData/
.swiftpm/configuration/registries.json
.swiftpm/xcode/package.xcworkspace/contents.xcworkspacedata
.netrc
EOF

cat > "$pkg_dir/Sources/$name/$name.swift" <<EOF
// SPDX-FileCopyrightText: 2026 Digg - Agency for digital government
//
// SPDX-License-Identifier: EUPL-1.2

import Foundation
EOF

cat > "$pkg_dir/Tests/${name}Tests/${name}Tests.swift" <<EOF
// SPDX-FileCopyrightText: 2026 Digg - Agency for digital government
//
// SPDX-License-Identifier: EUPL-1.2

import Testing

@testable import $name

struct ${name}Tests {
  @Test func placeholder() {
    #expect(Bool(true))
  }
}
EOF

PKG_NAME="$name" perl -0pi -e '
  my $n = $ENV{PKG_NAME};
  s/\n\ntargets:\n/\n  $n:\n    path: Packages\/$n\n\ntargets:\n/;
' "$root/project.yml"

PKG_NAME="$name" perl -0pi -e '
  my $n = $ENV{PKG_NAME};
  s/(  PackageTests:\n(?:.*\n)*?      targets:\n(?:[ ]+- package: .*\n)+)/$1        - package: $n\/${n}Tests\n/;
' "$root/project.yml"

echo "Created Packages/$name and updated project.yml"
echo "Run 'just generate' to regenerate the project"
