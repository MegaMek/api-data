// swift-tools-version:5.10
import PackageDescription

let package = Package(
  name: "mul-api",
  platforms: [
    .macOS(.v13)
  ],
  dependencies: [
    .package(url: "https://github.com/vapor/vapor.git", from: "4.92.6"),
    .package(url: "https://github.com/vapor/fluent.git", from: "4.9.0"),
    .package(url: "https://github.com/vapor/fluent-postgres-driver.git", from: "2.8.0"),
    .package(url: "https://github.com/vapor/leaf.git", from: "4.3.0"),
    .package(url: "https://github.com/CoreOffice/XMLCoder.git", from: "0.17.1"),
    .package(url: "https://github.com/vapor/redis.git", from: "4.10.0"),
    .package(url: "https://github.com/swiftcsv/SwiftCSV.git", from: "0.9.1"),
    .package(url: "https://github.com/vapor/queues-redis-driver.git", from: "1.1.1")
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
        .product(name: "QueuesRedisDriver", package: "queues-redis-driver")
      ]
    ),
    .testTarget(
      name: "AppTests",
      dependencies: [
        .target(name: "App"),
        .product(name: "XCTVapor", package: "vapor"),

        .product(name: "Vapor", package: "vapor"),
        .product(name: "Fluent", package: "Fluent"),
        .product(name: "FluentPostgresDriver", package: "fluent-postgres-driver"),
        .product(name: "Leaf", package: "leaf"),
        .product(name: "XMLCoder", package: "XMLCoder"),
        .product(name: "Redis", package: "Redis"),
        .product(name: "QueuesRedisDriver", package: "queues-redis-driver"),
        .product(name: "SwiftCSV", package: "SwiftCSV")
      ])
  ]
)
