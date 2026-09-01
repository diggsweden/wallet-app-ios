// swift-tools-version: 6.3

import PackageDescription

let package = Package(
  name: "WalletNetworking",
  platforms: [
    .iOS(.v17)
  ],
  products: [
    .library(
      name: "WalletNetworking",
      targets: ["WalletNetworking"],
    )
  ],
  targets: [
    .target(
      name: "WalletNetworking"
    ),
    .testTarget(
      name: "WalletNetworkingTests",
      dependencies: ["WalletNetworking"],
    ),
  ],
  swiftLanguageModes: [.v6],
)
