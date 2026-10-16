// SPDX-FileCopyrightText: 2026 Digg - Agency for digital government
//
// SPDX-License-Identifier: EUPL-1.2

// swift-tools-version: 6.3

import PackageDescription

let package = Package(
  name: "Trust",
  platforms: [
    .iOS(.v17)
  ],
  products: [
    .library(
      name: "Trust",
      targets: ["Trust"],
    )
  ],
  targets: [
    .target(
      name: "Trust"
    ),
    .testTarget(
      name: "TrustTests",
      dependencies: ["Trust"],
    ),
  ],
  swiftLanguageModes: [.v6],
)
