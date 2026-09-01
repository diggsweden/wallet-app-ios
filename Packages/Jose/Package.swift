// SPDX-FileCopyrightText: 2026 Digg - Agency for digital government
//
// SPDX-License-Identifier: EUPL-1.2

// swift-tools-version: 6.3

import PackageDescription

let package = Package(
  name: "Jose",
  platforms: [
    .iOS(.v17)
  ],
  products: [
    .library(
      name: "Jose",
      targets: ["Jose"],
    )
  ],
  dependencies: [
    .package(url: "https://github.com/beatt83/jose-swift.git", exact: "6.0.5")
  ],
  targets: [
    .target(
      name: "Jose",
      dependencies: [
        .product(name: "jose-swift", package: "jose-swift")
      ],
    ),
    .testTarget(
      name: "JoseTests",
      dependencies: ["Jose"],
    ),
  ],
  swiftLanguageModes: [.v6],
)
