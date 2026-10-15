// SPDX-FileCopyrightText: 2026 Digg - Agency for digital government
//
// SPDX-License-Identifier: EUPL-1.2

// swift-tools-version: 6.3

import PackageDescription

let package = Package(
  name: "QRScanner",
  platforms: [
    .iOS(.v17)
  ],
  products: [
    .library(
      name: "QRScanner",
      targets: ["QRScanner"],
    )
  ],
  dependencies: [
    .package(name: "DesignSystem", path: "../DesignSystem")
  ],
  targets: [
    .target(
      name: "QRScanner",
      dependencies: [
        .product(name: "DesignSystem", package: "DesignSystem")
      ],
    ),
    .testTarget(
      name: "QRScannerTests",
      dependencies: ["QRScanner"],
    ),
  ],
  swiftLanguageModes: [.v6],
)
