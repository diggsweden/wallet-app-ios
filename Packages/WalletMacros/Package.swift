// SPDX-FileCopyrightText: 2026 Digg - Agency for digital government
//
// SPDX-License-Identifier: EUPL-1.2

// swift-tools-version: 6.2

import CompilerPluginSupport
import PackageDescription

let package = Package(
  name: "WalletMacros",
  platforms: [
    .macOS(.v15),
    .iOS(.v17),
  ],
  products: [
    .library(
      name: "WalletMacros",
      targets: ["WalletMacros"]
    )
  ],
  dependencies: [
    .package(
      url: "https://github.com/swiftlang/swift-syntax.git",
      exact: "603.0.1"
    )
  ],
  targets: [
    .macro(
      name: "WalletMacrosPlugin",
      dependencies: [
        .product(name: "SwiftSyntax", package: "swift-syntax"),
        .product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
        .product(name: "SwiftCompilerPlugin", package: "swift-syntax"),
      ]
    ),
    .target(
      name: "WalletMacros",
      dependencies: ["WalletMacrosPlugin"]
    ),
  ]
)
