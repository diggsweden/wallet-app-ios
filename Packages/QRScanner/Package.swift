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
  targets: [
    .target(
      name: "QRScanner"
    ),
    .testTarget(
      name: "QRScannerTests",
      dependencies: ["QRScanner"],
    ),
  ],
  swiftLanguageModes: [.v6],
)
