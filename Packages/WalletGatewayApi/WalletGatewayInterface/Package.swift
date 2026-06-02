// swift-tools-version: 6.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "WalletGatewayInterface",
  products: [
    .library(
      name: "WalletGatewayInterface",
      targets: ["WalletGatewayInterface"]
    )
  ],
  targets: [
    .target(
      name: "WalletGatewayInterface"
    )
  ],
  swiftLanguageModes: [.v6]
)
