// SPDX-FileCopyrightText: 2026 Digg - Agency for digital government
//
// SPDX-License-Identifier: EUPL-1.2

// swift-tools-version: 6.2

import PackageDescription

let package = Package(
  name: "WalletGateway",
  platforms: [
    .iOS(.v17)
  ],
  products: [
    .library(
      name: "WalletGateway",
      targets: ["WalletGateway"],
    )
  ],
  dependencies: [
    .package(url: "https://github.com/apple/swift-openapi-runtime", from: "1.12.0"),
    .package(url: "https://github.com/apple/swift-openapi-urlsession", from: "1.3.1"),
    .package(url: "https://github.com/apple/swift-openapi-generator", from: "1.13.0"),
    .package(
      url: "https://github.com/diggsweden/SwiftAccessMechanism.git",
      branch: "chore/spm-vendored-xcframework",
    ),
    .package(name: "WalletGatewayInterface", path: "./WalletGatewayInterface"),
  ],
  targets: [
    .target(
      name: "WalletGateway",
      dependencies: [
        .product(name: "OpenAPIRuntime", package: "swift-openapi-runtime"),
        .product(name: "OpenAPIURLSession", package: "swift-openapi-urlsession"),
        .product(name: "SwiftAccessMechanism", package: "SwiftAccessMechanism"),
        .product(name: "WalletGatewayInterface", package: "WalletGatewayInterface"),
      ],
      plugins: [
        .plugin(name: "OpenAPIGenerator", package: "swift-openapi-generator")
      ],
    ),
    .testTarget(
      name: "WalletGatewayTests",
      dependencies: ["WalletGateway"],
    ),
  ],
)
