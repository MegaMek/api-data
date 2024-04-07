//
//  BattleTech.ErasControllerTest.swift
//
//  Created by Richard Hancock on 2024-02-22.
//

import Fluent
import XCTVapor

@testable import App

final class ErasControllerTests: XCTestCase {
  var path = "/battletech/eras"

  func testIndex() async throws {
    let app = Application(.testing)
    defer { app.shutdown() }
    try await configureApp(app)

    _ = try await BattleTech.Era.create(on: app.db(.primary))
    let eraCount = try await BattleTech.Era.query(on: app.db(.replica)).count()

    try app.test(
      .GET, path,
      afterResponse: { response in
        let eras = try response.content.decode([BattleTech.Era].self)
        XCTAssertEqual(eras.count, eraCount)
      })
  }

  func testShow() async throws {
    let app = Application(.testing)
    defer { app.shutdown() }
    try await configureApp(app)

    let era = try await BattleTech.Era.create(on: app.db(.primary))
    let showPath = "\(path)/\(era.id!)"

    try app.test(
      .GET, showPath,
      afterResponse: { response in
        let returnedEra = try response.content.decode(BattleTech.Era.self)
        XCTAssertEqual(era.name, returnedEra.name)
      })
  }

  func testShowNotFound() async throws {
    let app = Application(.testing)
    defer { app.shutdown() }
    try await configureApp(app)

    let notFoundPath = "\(path)/NOT-A-UUID"

    try app.test(
      .GET, notFoundPath,
      afterResponse: { response in
        XCTAssertEqual(response.status, .notFound)
      })
  }

  func testDelete() async throws {
    let app = Application(.testing)
    defer { app.shutdown() }
    try await configureApp(app)

    let era = try await BattleTech.Era.create(on: app.db(.primary))
    let showPath = "\(path)/\(era.id!)"

    try app.test(
      .DELETE, showPath,
      afterResponse: { response in
        XCTAssertEqual(response.status, .noContent)
      })
  }

  func testImport() async throws {
    let app = Application(.testing)
    defer { app.shutdown() }
    try await configureApp(app)

    let eraCount = try await BattleTech.Era.query(on: app.db(.replica)).count()

    let (testFileHandle, testFileRegion) = try await app.fileio.openFile(
      path: "Tests/Resources/BattleTech/eras.xml",
      eventLoop: app.eventLoopGroup.next()
    ).get()

    let testFileByteBuffer = try await app.fileio.read(
      fileRegion: testFileRegion, allocator: .init())
    let eraMassImport = EraMassImport(file: File(data: testFileByteBuffer, filename: "eras.xml"))
    try testFileHandle.close()

    let massImportPath = "\(path)/import"

    try await app.test(
      .POST, massImportPath,
      beforeRequest: { request in
        try request.content.encode(eraMassImport)
      },
      afterResponse: { response in
        XCTAssertEqual(response.status, .created)
        let postEraCount = try await BattleTech.Era.query(on: app.db(.replica)).count()
        XCTAssertNotEqual(eraCount, postEraCount)
      })
  }

  func testDuplicateImport() async throws {
    let app = Application(.testing)
    defer { app.shutdown() }
    try await configureApp(app)

    let (testFileHandle, testFileRegion) = try await app.fileio.openFile(
      path: "Tests/Resources/BattleTech/eras.xml",
      eventLoop: app.eventLoopGroup.next()
    ).get()

    let testFileByteBuffer = try await app.fileio.read(
      fileRegion: testFileRegion, allocator: .init())
    let eraMassImport = EraMassImport(file: File(data: testFileByteBuffer, filename: "eras.xml"))
    try testFileHandle.close()

    let massImportPath = "\(path)/import"

    try app.test(
      .POST, massImportPath,
      beforeRequest: { request in
        try request.content.encode(eraMassImport)
      },
      afterResponse: { response in
        XCTAssertEqual(response.status, .created)
      })

    let eraCount = try await BattleTech.Era.query(on: app.db(.replica)).count()

    try await app.test(
      .POST, massImportPath,
      beforeRequest: { request in
        try request.content.encode(eraMassImport)
      },
      afterResponse: { response in
        let postCount = try await BattleTech.Era.query(on: app.db(.replica)).count()

        XCTAssertEqual(response.status, .created)
        XCTAssertEqual(eraCount, postCount)
      })
  }

  private func configureApp(_ app: Application) async throws {
    try await configure(app)
    try await app.autoRevert()
    try await app.autoMigrate()
  }
}
