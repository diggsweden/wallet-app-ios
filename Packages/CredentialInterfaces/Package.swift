// SPDX-FileCopyrightText: 2026 Digg - Agency for digital government
//
// SPDX-License-Identifier: EUPL-1.2

// swift-tools-version: 6.0

import PackageDescription

let package = Package(
  name: "CredentialInterfaces",
  platforms: [
    .iOS(.v17)
  ],
  products: [
    .library(
      name: "CredentialInterfaces",
      targets: ["CredentialInterfaces"]
    )
  ],
  targets: [
    .target(
      name: "CredentialInterfaces"
    )
  ],
  swiftLanguageModes: [.v6]
)
