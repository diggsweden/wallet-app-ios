// SPDX-FileCopyrightText: 2026 Digg - Agency for digital government
//
// SPDX-License-Identifier: EUPL-1.2

// swift-tools-version: 6.3

import PackageDescription

let package = Package(
  name: "WalletNetworking",
  platforms: [
    .iOS(.v17)
  ],
  products: [
    .library(
      name: "WalletNetworking",
      targets: ["WalletNetworking"],
    )
  ],
  dependencies: [
    .package(name: "WalletMacros", path: "../WalletMacros")
  ],
  targets: [
    .target(
      name: "WalletNetworking"
    ),
    .testTarget(
      name: "WalletNetworkingTests",
      dependencies: [
        "WalletNetworking",
        .product(name: "WalletMacros", package: "WalletMacros"),
      ],
    ),
  ],
  swiftLanguageModes: [.v6],
)
