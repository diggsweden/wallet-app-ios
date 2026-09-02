// SPDX-FileCopyrightText: 2026 Digg - Agency for digital government
//
// SPDX-License-Identifier: EUPL-1.2

// swift-tools-version: 6.3

import PackageDescription

let package = Package(
  name: "Presentation",
  platforms: [
    .iOS(.v17)
  ],
  products: [
    .library(
      name: "Presentation",
      targets: ["Presentation"],
    )
  ],
  dependencies: [
    .package(
      url: "https://github.com/eu-digital-identity-wallet/eudi-lib-ios-openid4vp-swift.git",
      exact: "0.41.0",
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
      name: "Presentation",
      dependencies: [
        .product(name: "OpenID4VP", package: "eudi-lib-ios-openid4vp-swift"),
        .product(name: "eudi-lib-sdjwt-swift", package: "eudi-lib-sdjwt-swift"),
        .product(name: "CredentialInterfaces", package: "CredentialInterfaces"),
        .product(name: "Jose", package: "Jose"),
        .product(name: "OpenId4VCInterface", package: "OpenId4VCInterface"),
        .product(name: "SdJwtClaims", package: "SdJwtClaims"),
        .product(name: "WalletNetworking", package: "WalletNetworking"),
      ],
    ),
    .testTarget(
      name: "PresentationTests",
      dependencies: [
        "Presentation",
        .product(name: "eudi-lib-sdjwt-swift", package: "eudi-lib-sdjwt-swift"),
        .product(name: "CredentialInterfaces", package: "CredentialInterfaces"),
        .product(name: "Jose", package: "Jose"),
        .product(name: "OpenId4VCInterface", package: "OpenId4VCInterface"),
      ],
    ),
  ],
  swiftLanguageModes: [.v6],
)
