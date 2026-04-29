// swift-tools-version: 5.10
import PackageDescription

let package = Package(
  name: "SwiftDataMigrate",
  platforms: [.macOS(.v13)],
  products: [
    .executable(name: "swiftdata-migrate", targets: ["SwiftDataMigrate"])
  ],
  dependencies: [
    .package(url: "https://github.com/apple/swift-argument-parser.git", from: "1.3.0")
  ],
  targets: [
    .executableTarget(
      name: "SwiftDataMigrate",
      dependencies: [
        .product(name: "ArgumentParser", package: "swift-argument-parser")
      ]
    )
  ]
)
