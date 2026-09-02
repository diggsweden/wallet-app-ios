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
    .package(url: "https://github.com/beatt83/jose-swift.git", exact: "6.0.5"),
    .package(name: "WalletMacros", path: "../WalletMacros"),
    .package(name: "WalletNetworking", path: "../WalletNetworking"),
  ],
  targets: [
    .target(
      name: "Jose",
      dependencies: [
        .product(name: "jose-swift", package: "jose-swift"),
        .product(name: "WalletNetworking", package: "WalletNetworking"),
      ],
    ),
    .testTarget(
      name: "JoseTests",
      dependencies: [
        "Jose",
        .product(name: "WalletMacros", package: "WalletMacros"),
        .product(name: "WalletNetworking", package: "WalletNetworking"),
      ],
    ),
  ],
  swiftLanguageModes: [.v6],
)
