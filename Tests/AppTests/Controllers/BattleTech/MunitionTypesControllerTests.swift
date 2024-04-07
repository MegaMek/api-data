//
//  BattleTech.FactionsControllerTest.swift
//
//  Created by Richard Hancock on 2024-02-22.
//

import Fluent
import XCTVapor

@testable import App

final class MunitionTypesControllerTests: XCTestCase {
  var path = "/battletech/munition-types"

  func testIndex() async throws {
    let app = Application(.testing)
    defer { app.shutdown() }
    try await configureApp(app)

    _ = try await BattleTech.MunitionType.create(on: app.db(.primary))
    let munitionTypeCount = try await BattleTech.MunitionType.query(on: app.db(.replica)).count()

    try app.test(
      .GET, path,
      afterResponse: { response in
        let munitionTypes = try response.content.decode([BattleTech.MunitionType].self)
        XCTAssertEqual(munitionTypes.count, munitionTypeCount)
      })
  }

  func testShow() async throws {
    let app = Application(.testing)
    defer { app.shutdown() }
    try await configureApp(app)

    let munitionType = try await BattleTech.MunitionType.create(on: app.db(.primary))
    let showPath = "\(path)/\(munitionType.id!)"

    try app.test(
      .GET, showPath,
      afterResponse: { response in
        let returnedMunitionType = try response.content.decode(BattleTech.MunitionType.self)
        XCTAssertEqual(munitionType.name, returnedMunitionType.name)
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

    let munitionType = try await BattleTech.MunitionType.create(on: app.db(.primary))
    let showPath = "\(path)/\(munitionType.id!)"

    try app.test(
      .DELETE, showPath,
      afterResponse: { response in
        XCTAssertEqual(response.status, .noContent)
      })
  }

  func testAmmo() async throws {
    let app = Application(.testing)
    defer { app.shutdown() }
    try await configureApp(app)

    let ammo = try await BattleTech.Ammo.create(on: app.db(.primary))
    let showPath = "\(path)/\(ammo.$munitionType.id)/ammo"

    try app.test(
      .GET, showPath,
      afterResponse: { response in
        let returnedAmmo = try response.content.decode(Page<BattleTech.Ammo>.self)
        XCTAssertEqual(1, returnedAmmo.metadata.total)
      })
  }

  private func configureApp(_ app: Application) async throws {
    try await configure(app)
    try await app.autoRevert()
    try await app.autoMigrate()
  }
}
