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
    .package(name: "CredentialInterfaces", path: "../CredentialInterfaces"),
    .package(name: "Jose", path: "../Jose"),
    .package(name: "OpenId4VCInterface", path: "../OpenId4VCInterface"),
    .package(name: "SdJwt", path: "../SdJwt"),
    .package(name: "WalletMacros", path: "../WalletMacros"),
    .package(name: "WalletNetworking", path: "../WalletNetworking"),
  ],
  targets: [
    .target(
      name: "Issuance",
      dependencies: [
        .product(name: "OpenID4VCI", package: "eudi-lib-ios-openid4vci-swift"),
        .product(name: "CredentialInterfaces", package: "CredentialInterfaces"),
        .product(name: "Jose", package: "Jose"),
        .product(name: "OpenId4VCInterface", package: "OpenId4VCInterface"),
        .product(name: "SdJwt", package: "SdJwt"),
        .product(name: "WalletNetworking", package: "WalletNetworking"),
      ],
    ),
    .testTarget(
      name: "IssuanceTests",
      dependencies: [
        "Issuance",
        .product(name: "OpenID4VCI", package: "eudi-lib-ios-openid4vci-swift"),
        .product(name: "CredentialInterfacesTestSupport", package: "CredentialInterfaces"),
        .product(name: "Jose", package: "Jose"),
        .product(name: "JoseTestSupport", package: "Jose"),
        .product(name: "OpenId4VCInterface", package: "OpenId4VCInterface"),
        .product(name: "OpenId4VCInterfaceTestSupport", package: "OpenId4VCInterface"),
        .product(name: "WalletMacros", package: "WalletMacros"),
        .product(name: "WalletNetworking", package: "WalletNetworking"),
        .product(name: "WalletNetworkingTestSupport", package: "WalletNetworking"),
      ],
    ),
  ],
  swiftLanguageModes: [.v6],
)
