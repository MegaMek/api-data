//
//  BattleTech.FactionsControllerTest.swift
//
//  Created by Richard Hancock on 2024-02-22.
//

import Fluent
import XCTVapor

@testable import App

final class RulesControllerTests: XCTestCase {
    var path = "/battletech/rules"

    func testIndex() async throws {
        let app = Application(.testing)
        defer { app.shutdown() }
        try await configureApp(app)

        _ = try await BattleTech.Rule.create(on: app.db)
        let ruleCount = try await BattleTech.Rule.query(on: app.db).count()

        try app.test(
            .GET, path,
            afterResponse: { response in
                let rules = try response.content.decode([BattleTech.Rule].self)
                XCTAssertEqual(rules.count, ruleCount)
            })
    }

    func testShow() async throws {
        let app = Application(.testing)
        defer { app.shutdown() }
        try await configureApp(app)

        let rule = try await BattleTech.Rule.create(on: app.db)
        let showPath = "\(path)/\(rule.id!)"

        try app.test(
            .GET, showPath,
            afterResponse: { response in
                let returnedRule = try response.content.decode(BattleTech.Rule.self)
                XCTAssertEqual(rule.name, returnedRule.name)
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

        let rule = try await BattleTech.Rule.create(on: app.db)
        let showPath = "\(path)/\(rule.id!)"

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

        let ammo = try await BattleTech.Ammo.create(on: app.db)
        try await ammo.$rules.load(on: app.db)
        let rule = ammo.rules.first!

        let showPath = "\(path)/\(rule.id!)/ammo"

        try app.test(
            .GET, showPath,
            afterResponse: { response in
                let returnedAmmo = try response.content.decode(Page<BattleTech.Ammo>.self)
                XCTAssertEqual(1, returnedAmmo.metadata.total)
            })
    }

    func testEquipment() async throws {
        let app = Application(.testing)
        defer { app.shutdown() }
        try await configureApp(app)

        let equipment = try await BattleTech.Equipment.create(on: app.db)
        try await equipment.$rules.load(on: app.db)
        let rule = equipment.rules.first!

        let showPath = "\(path)/\(rule.id!)/equipment"

        try app.test(
            .GET, showPath,
            afterResponse: { response in
                let returnedEquipment = try response.content.decode(Page<BattleTech.Equipment>.self)
                XCTAssertEqual(1, returnedEquipment.metadata.total)
            })
    }

    func testWeapons() async throws {
        let app = Application(.testing)
        defer { app.shutdown() }
        try await configureApp(app)

        let weapon = try await BattleTech.Weapon.create(on: app.db)
        try await weapon.$rules.load(on: app.db)
        let rule = weapon.rules.first!

        let showPath = "\(path)/\(rule.id!)/weapons"

        try app.test(
            .GET, showPath,
            afterResponse: { response in
                let returnedWeapons = try response.content.decode(Page<BattleTech.Weapon>.self)
                XCTAssertEqual(1, returnedWeapons.metadata.total)
            })
    }

    private func configureApp(_ app: Application) async throws {
        try await configure(app)
        try await app.autoRevert()
        try await app.autoMigrate()
    }
}
