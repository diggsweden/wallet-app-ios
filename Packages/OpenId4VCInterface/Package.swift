// SPDX-FileCopyrightText: 2026 Digg - Agency for digital government
//
// SPDX-License-Identifier: EUPL-1.2

// swift-tools-version: 6.3

import PackageDescription

let package = Package(
  name: "OpenId4VCInterface",
  platforms: [
    .iOS(.v17)
  ],
  products: [
    .library(
      name: "OpenId4VCInterface",
      targets: ["OpenId4VCInterface"],
    ),
    .library(
      name: "OpenId4VCInterfaceTestSupport",
      targets: ["OpenId4VCInterfaceTestSupport"],
    ),
  ],
  dependencies: [
    .package(name: "CredentialInterfaces", path: "../CredentialInterfaces"),
    .package(name: "Jose", path: "../Jose"),
  ],
  targets: [
    .target(
      name: "OpenId4VCInterface",
      dependencies: [
        .product(name: "CredentialInterfaces", package: "CredentialInterfaces"),
        .product(name: "Jose", package: "Jose"),
      ],
    ),
    .target(
      name: "OpenId4VCInterfaceTestSupport",
      dependencies: [
        "OpenId4VCInterface",
        .product(name: "Jose", package: "Jose"),
      ],
    ),
    .testTarget(
      name: "OpenId4VCInterfaceTests",
      dependencies: ["OpenId4VCInterface"],
    ),
  ],
  swiftLanguageModes: [.v6],
)
