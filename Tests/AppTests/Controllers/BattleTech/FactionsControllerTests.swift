//
//  BattleTech.FactionsControllerTest.swift
//
//  Created by Richard Hancock on 2024-02-22.
//

import Fluent
import XCTVapor

@testable import App

final class FactionsControllerTests: XCTestCase {
  var path = "/battletech/factions"

  func testIndex() async throws {
    let app = Application(.testing)
    defer { app.shutdown() }
    try await configureApp(app)

    _ = try await BattleTech.Faction.create(on: app.db(.primary))
    let factionCount = try await BattleTech.Faction.query(on: app.db(.replica)).count()

    try app.test(
      .GET, path,
      afterResponse: { response in
        let factions = try response.content.decode([BattleTech.Faction].self)
        XCTAssertEqual(factions.count, factionCount)
      })
  }

  func testShow() async throws {
    let app = Application(.testing)
    defer { app.shutdown() }
    try await configureApp(app)

    let faction = try await BattleTech.Faction.create(on: app.db(.primary))
    let showPath = "\(path)/\(faction.id!)"

    try app.test(
      .GET, showPath,
      afterResponse: { response in
        let returnedFaction = try response.content.decode(BattleTech.Faction.self)
        XCTAssertEqual(faction.factionKey, returnedFaction.factionKey)
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

    let faction = try await BattleTech.Faction.create(on: app.db(.primary))
    let showPath = "\(path)/\(faction.id!)"

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

    let factionCount = try await BattleTech.Faction.query(on: app.db(.replica)).count()

    let (testFileHandle, testFileRegion) = try await app.fileio.openFile(
      path: "Tests/Resources/BattleTech/factions.xml",
      eventLoop: app.eventLoopGroup.next()
    ).get()

    let testFileByteBuffer = try await app.fileio.read(
      fileRegion: testFileRegion, allocator: .init())
    let factionMassImport = FactionMassImport(
      file: File(data: testFileByteBuffer, filename: "factions.xml"))
    try testFileHandle.close()

    let massImportPath = "\(path)/import"

    try await app.test(
      .POST, massImportPath,
      beforeRequest: { request in
        try request.content.encode(factionMassImport)
      },
      afterResponse: { response in
        XCTAssertEqual(response.status, .created)
        let postFactionCount = try await BattleTech.Faction.query(on: app.db(.replica)).count()
        XCTAssertNotEqual(factionCount, postFactionCount)
      })
  }

  func testDuplicateImport() async throws {
    let app = Application(.testing)
    defer { app.shutdown() }
    try await configureApp(app)

    let (testFileHandle, testFileRegion) = try await app.fileio.openFile(
      path: "Tests/Resources/BattleTech/factions.xml",
      eventLoop: app.eventLoopGroup.next()
    ).get()

    let testFileByteBuffer = try await app.fileio.read(
      fileRegion: testFileRegion, allocator: .init())
    let factionMassImport = FactionMassImport(
      file: File(data: testFileByteBuffer, filename: "factions.xml"))
    try testFileHandle.close()

    let massImportPath = "\(path)/import"

    try app.test(
      .POST, massImportPath,
      beforeRequest: { request in
        try request.content.encode(factionMassImport)
      },
      afterResponse: { response in
        XCTAssertEqual(response.status, .created)
      })

    let factionCount = try await BattleTech.Faction.query(on: app.db(.replica)).count()

    try await app.test(
      .POST, massImportPath,
      beforeRequest: { request in
        try request.content.encode(factionMassImport)
      },
      afterResponse: { response in
        let postCount = try await BattleTech.Faction.query(on: app.db(.replica)).count()

        XCTAssertEqual(response.status, .created)
        XCTAssertEqual(factionCount, postCount)
      })
  }

  private func configureApp(_ app: Application) async throws {
    try await configure(app)
    try await app.autoRevert()
    try await app.autoMigrate()
  }
}
