// SPDX-FileCopyrightText: 2026 Digg - Agency for digital government
//
// SPDX-License-Identifier: EUPL-1.2

// swift-tools-version: 6.3

import PackageDescription

let package = Package(
  name: "DesignSystem",
  platforms: [
    .iOS(.v17)
  ],
  products: [
    .library(
      name: "DesignSystem",
      targets: ["DesignSystem"]
    )
  ],
  targets: [
    .target(
      name: "DesignSystem",
      resources: [
        .process("Resources/Fonts")
      ]
    )
  ],
  swiftLanguageModes: [.v6]
)
