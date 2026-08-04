// SPDX-FileCopyrightText: 2026 Digg - Agency for digital government
//
// SPDX-License-Identifier: EUPL-1.2

// swift-tools-version: 6.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "WalletGatewayInterface",
  platforms: [
    .iOS(.v17)
  ],
  products: [
    .library(
      name: "WalletGatewayInterface",
      targets: ["WalletGatewayInterface"],
    )
  ],
  targets: [
    .target(
      name: "WalletGatewayInterface"
    )
  ],
  swiftLanguageModes: [.v6],
)
