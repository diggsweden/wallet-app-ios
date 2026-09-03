// SPDX-FileCopyrightText: 2026 Digg - Agency for digital government
//
// SPDX-License-Identifier: EUPL-1.2

// swift-tools-version: 6.3

import PackageDescription

let package = Package(
  name: "SdJwtClaims",
  platforms: [
    .iOS(.v17)
  ],
  products: [
    .library(
      name: "SdJwtClaims",
      targets: ["SdJwtClaims"],
    )
  ],
  dependencies: [
    .package(
      url: "https://github.com/eu-digital-identity-wallet/eudi-lib-sdjwt-swift.git",
      exact: "0.14.6",
    ),
    .package(url: "https://github.com/SwiftyJSON/SwiftyJSON.git", from: "5.0.2"),
    .package(name: "CredentialInterfaces", path: "../CredentialInterfaces"),
  ],
  targets: [
    .target(
      name: "SdJwtClaims",
      dependencies: [
        .product(name: "eudi-lib-sdjwt-swift", package: "eudi-lib-sdjwt-swift"),
        .product(name: "SwiftyJSON", package: "SwiftyJSON"),
        .product(name: "CredentialInterfaces", package: "CredentialInterfaces"),
      ],
    ),
    .testTarget(
      name: "SdJwtClaimsTests",
      dependencies: [
        "SdJwtClaims",
        .product(name: "CredentialInterfacesTestSupport", package: "CredentialInterfaces"),
      ],
    ),
  ],
  swiftLanguageModes: [.v6],
)
