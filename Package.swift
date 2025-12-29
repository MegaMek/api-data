// swift-tools-version:6.2
import PackageDescription

let package = Package(
  name: "mul-api",
  platforms: [
    .macOS(.v14)
  ],
  dependencies: [
    .package(url: "https://github.com/vapor/vapor.git", from: "4.120.0"),
    .package(url: "https://github.com/vapor/fluent.git", from: "4.13.0"),
    .package(url: "https://github.com/vapor/fluent-postgres-driver.git", from: "2.12.0"),
    .package(url: "https://github.com/vapor/leaf.git", from: "4.5.1"),
    .package(url: "https://github.com/CoreOffice/XMLCoder.git", from: "0.17.1"),
    .package(url: "https://github.com/swiftcsv/SwiftCSV.git", from: "0.10.0"),
    .package(url: "https://github.com/apple/swift-nio.git", from: "2.92.0"),
    .package(url: "https://github.com/vapor-community/sendgrid.git", from: "6.0.0"),
    .package(url: "https://github.com/vapor-community/vapor-queues-fluent-driver.git", from: "3.1.0"),
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
        .product(name: "XCTVapor", package: "vapor"),
      ]),
  ]
)

var swiftSettings: [SwiftSetting] {
  [
    .enableExperimentalFeature("StrictConcurrency")
  ]
}
