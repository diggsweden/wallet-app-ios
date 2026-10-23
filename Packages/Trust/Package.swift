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
  dependencies: [
    .package(name: "WalletGatewayInterface", path: "../WalletGatewayApi/WalletGatewayInterface"),
    .package(name: "Jose", path: "../Jose"),
    .package(name: "WalletMacros", path: "../WalletMacros"),
  ],
  targets: [
    .target(
      name: "Trust",
      dependencies: [
        .product(name: "Jose", package: "Jose"),
        .product(name: "WalletGatewayInterface", package: "WalletGatewayInterface"),
      ],
    ),
    .testTarget(
      name: "TrustTests",
      dependencies: [
        "Trust",
        .product(name: "Jose", package: "Jose"),
        .product(name: "WalletGatewayInterface", package: "WalletGatewayInterface"),
        .product(name: "WalletMacros", package: "WalletMacros"),
      ],
    ),
  ],
  swiftLanguageModes: [.v6],
)
