//
//  BattleTech.FactionsControllerTest.swift
//
//  Created by Richard Hancock on 2024-02-22.
//

import Fluent
import XCTVapor

@testable import App

final class WeaponsControllerTests: XCTestCase {
  var path = "/battletech/weapons"

  func testIndex() async throws {
    let app = Application(.testing)
    defer { app.shutdown() }
    try await configureApp(app)

    _ = try await BattleTech.Weapon.create(on: app.db(.primary))
    let weaponCount = try await BattleTech.Weapon.query(on: app.db(.replica)).count()

    try app.test(
      .GET, path,
      afterResponse: { response in
        let weapons = try response.content.decode(Page<BattleTech.Weapon>.self)
        XCTAssertEqual(weapons.metadata.total, weaponCount)
      })
  }

  func testShow() async throws {
    let app = Application(.testing)
    defer { app.shutdown() }
    try await configureApp(app)

    let weapon = try await BattleTech.Weapon.create(on: app.db(.primary))
    let showPath = "\(path)/\(weapon.id!)"

    try app.test(
      .GET, showPath,
      afterResponse: { response in
        let returnedWeapon = try response.content.decode(BattleTech.Weapon.self)
        XCTAssertEqual(weapon.name, returnedWeapon.name)
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

    let weapon = try await BattleTech.Weapon.create(on: app.db(.primary))
    let showPath = "\(path)/\(weapon.id!)"

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

    let (testFileHandle, testFileRegion) = try await app.fileio.openFile(
      path: "Tests/Resources/BattleTech/weapons.csv",
      eventLoop: app.eventLoopGroup.next()
    ).get()

    let testFileByteBuffer = try await app.fileio.read(
      fileRegion: testFileRegion, allocator: .init())
    let weaponsMassImport = WeaponMassImport(
      file: File(data: testFileByteBuffer, filename: "weapons.csv"))
    try testFileHandle.close()

    let massImportPath = "\(path)/import"

    try app.test(
      .POST, massImportPath,
      beforeRequest: { request in
        try request.content.encode(weaponsMassImport)
      },
      afterResponse: { response in
        XCTAssertEqual(response.status, .created)
        XCTAssertNotNil(app.queues.queue.pop())
      })

    _ = app.redis.send(command: "FLUSHDB")
  }

  private func configureApp(_ app: Application) async throws {
    try await configure(app)
    try await app.autoRevert()
    try await app.autoMigrate()
  }
}
