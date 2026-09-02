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
    )
  ],
  dependencies: [
    .package(name: "CredentialInterfaces", path: "../CredentialInterfaces")
  ],
  targets: [
    .target(
      name: "OpenId4VCInterface",
      dependencies: [
        .product(name: "CredentialInterfaces", package: "CredentialInterfaces")
      ],
    ),
    .testTarget(
      name: "OpenId4VCInterfaceTests",
      dependencies: ["OpenId4VCInterface"],
    ),
  ],
  swiftLanguageModes: [.v6],
)
