// swift-tools-version:6.0
import PackageDescription

let package = Package(
  name: "mul-api",
  platforms: [
    .macOS(.v13)
  ],
  dependencies: [
    .package(url: "https://github.com/vapor/vapor.git", from: "4.105.2"),
    .package(url: "https://github.com/vapor/fluent.git", from: "4.11.0"),
    .package(url: "https://github.com/vapor/fluent-postgres-driver.git", from: "2.9.2"),
    .package(url: "https://github.com/vapor/leaf.git", from: "4.4.0"),
    .package(url: "https://github.com/CoreOffice/XMLCoder.git", from: "0.17.1"),
    .package(url: "https://github.com/vapor/redis.git", from: "4.11.0"),
    .package(url: "https://github.com/swiftcsv/SwiftCSV.git", from: "0.10.0"),
    .package(url: "https://github.com/vapor/queues-redis-driver.git", from: "1.1.2"),
    .package(url: "https://github.com/apple/swift-nio.git", from: "2.74.0"),
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
        .product(name: "Redis", package: "Redis"),
        .product(name: "SwiftCSV", package: "SwiftCSV"),
        .product(name: "QueuesRedisDriver", package: "queues-redis-driver"),
        .product(name: "NIOCore", package: "swift-nio"),
        .product(name: "NIOPosix", package: "swift-nio"),
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
