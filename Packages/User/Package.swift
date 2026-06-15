// SPDX-FileCopyrightText: 2026 Digg - Agency for digital government
//
// SPDX-License-Identifier: EUPL-1.2

// swift-tools-version: 6.0

import PackageDescription

let package = Package(
  name: "User",
  platforms: [
    .iOS(.v17)
  ],
  products: [
    .library(
      name: "User",
      targets: ["User"]
    )
  ],
  dependencies: [
    .package(name: "CredentialInterfaces", path: "../CredentialInterfaces"),
    .package(name: "WalletGatewayInterface", path: "../WalletGatewayApi/WalletGatewayInterface"),
  ],
  targets: [
    .target(
      name: "User",
      dependencies: [
        .product(name: "CredentialInterfaces", package: "CredentialInterfaces"),
        .product(name: "WalletGatewayInterface", package: "WalletGatewayInterface"),
      ]
    ),
    .testTarget(
      name: "UserTests",
      dependencies: ["User"]
    ),
  ],
  swiftLanguageModes: [.v6]
)
