// SPDX-FileCopyrightText: 2026 Digg - Agency for digital government
//
// SPDX-License-Identifier: EUPL-1.2

// swift-tools-version: 6.3

import PackageDescription

let package = Package(
  name: "UIComponents",
  platforms: [
    .iOS(.v17)
  ],
  products: [
    .library(
      name: "UIComponents",
      targets: ["UIComponents"],
    )
  ],
  dependencies: [
    .package(name: "CredentialInterfaces", path: "../CredentialInterfaces"),
    .package(name: "DesignSystem", path: "../DesignSystem"),
  ],
  targets: [
    .target(
      name: "UIComponents",
      dependencies: [
        .product(name: "CredentialInterfaces", package: "CredentialInterfaces"),
        .product(name: "DesignSystem", package: "DesignSystem"),
      ],
    ),
    .testTarget(
      name: "UIComponentsTests",
      dependencies: ["UIComponents"],
    ),
  ],
  swiftLanguageModes: [.v6],
)
