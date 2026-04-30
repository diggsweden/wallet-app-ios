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
      targets: ["WalletGateway"]
    )
  ],
  dependencies: [
    .package(url: "https://github.com/apple/swift-openapi-runtime", from: "1.11.0"),
    .package(url: "https://github.com/apple/swift-openapi-urlsession", from: "1.3.0"),
    .package(url: "https://github.com/apple/swift-openapi-generator", from: "1.12.0"),
    .package(name: "SwiftAccessMechanism", path: "../../SwiftAccessMechanism"),
  ],
  targets: [
    .target(
      name: "WalletGateway",
      dependencies: [
        .product(name: "OpenAPIRuntime", package: "swift-openapi-runtime"),
        .product(name: "OpenAPIURLSession", package: "swift-openapi-urlsession"),
        .product(name: "SwiftAccessMechanism", package: "SwiftAccessMechanism"),
      ],
      plugins: [
        .plugin(name: "OpenAPIGenerator", package: "swift-openapi-generator")
      ]
    )
  ]
)
