// swift-tools-version:6.3
import PackageDescription

let package = Package(
  name: "mul-api",
  platforms: [
    .macOS(.v26)
  ],
  dependencies: [
    .package(url: "https://github.com/vapor/vapor.git", from: "4.122.0"),
    .package(url: "https://github.com/vapor/fluent.git", from: "4.13.0"),
    .package(url: "https://github.com/vapor/fluent-postgres-driver.git", from: "2.12.0"),
    .package(url: "https://github.com/vapor/leaf.git", from: "4.5.2"),
    .package(url: "https://github.com/CoreOffice/XMLCoder.git", from: "0.18.2"),
    .package(url: "https://github.com/swiftcsv/SwiftCSV.git", from: "0.10.0"),
    .package(url: "https://github.com/apple/swift-nio.git", from: "2.101.3"),
    .package(url: "https://github.com/vapor-community/sendgrid.git", from: "6.0.0"),
    .package(url: "https://github.com/vapor-community/vapor-queues-fluent-driver.git", from: "3.2.0"),
  ],
  targets: [
    .executableTarget(
      name: "App",
      dependencies: [
        .product(name: "Fluent", package: "fluent"),
        .product(name: "FluentPostgresDriver", package: "fluent-postgres-driver"),
        .product(name: "Leaf", package: "leaf"),
        .product(name: "Vapor", package: "vapor"),
        .product(name: "XMLCoder", package: "XMLCoder"),
        .product(name: "SwiftCSV", package: "SwiftCSV"),
        .product(name: "SendGrid", package: "sendgrid"),
        .product(name: "NIOCore", package: "swift-nio"),
        .product(name: "NIOPosix", package: "swift-nio"),
        .product(name: "QueuesFluentDriver", package: "vapor-queues-fluent-driver"),
      ]
    ),
    .testTarget(
      name: "AppTests",
      dependencies: [
        .target(name: "App"),
        .product(name: "VaporTesting", package: "vapor"),
        .product(name: "_NIOFileSystem", package: "swift-nio"),
      ]),
  ]
)

var swiftSettings: [SwiftSetting] {
  [
    .enableExperimentalFeature("StrictConcurrency")
  ]
}
