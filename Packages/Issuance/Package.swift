// SPDX-FileCopyrightText: 2026 Digg - Agency for digital government
//
// SPDX-License-Identifier: EUPL-1.2

// swift-tools-version: 6.3

import PackageDescription

let package = Package(
  name: "Issuance",
  platforms: [
    .iOS(.v17)
  ],
  products: [
    .library(
      name: "Issuance",
      targets: ["Issuance"],
    )
  ],
  dependencies: [
    .package(
      url: "https://github.com/eu-digital-identity-wallet/eudi-lib-ios-openid4vci-swift.git",
      exact: "0.53.1",
    ),
    .package(
      url: "https://github.com/eu-digital-identity-wallet/eudi-lib-sdjwt-swift.git",
      exact: "0.14.6",
    ),
    .package(name: "CredentialInterfaces", path: "../CredentialInterfaces"),
    .package(name: "Jose", path: "../Jose"),
    .package(name: "OpenId4VCInterface", path: "../OpenId4VCInterface"),
    .package(name: "SdJwtClaims", path: "../SdJwtClaims"),
    .package(name: "WalletNetworking", path: "../WalletNetworking"),
  ],
  targets: [
    .target(
      name: "Issuance",
      dependencies: [
        .product(name: "OpenID4VCI", package: "eudi-lib-ios-openid4vci-swift"),
        .product(name: "eudi-lib-sdjwt-swift", package: "eudi-lib-sdjwt-swift"),
        .product(name: "CredentialInterfaces", package: "CredentialInterfaces"),
        .product(name: "Jose", package: "Jose"),
        .product(name: "OpenId4VCInterface", package: "OpenId4VCInterface"),
        .product(name: "SdJwtClaims", package: "SdJwtClaims"),
        .product(name: "WalletNetworking", package: "WalletNetworking"),
      ],
    ),
    .testTarget(
      name: "IssuanceTests",
      dependencies: [
        "Issuance",
        .product(name: "Jose", package: "Jose"),
        .product(name: "OpenId4VCInterface", package: "OpenId4VCInterface"),
      ],
    ),
  ],
  swiftLanguageModes: [.v6],
)
