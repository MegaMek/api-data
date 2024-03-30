//
//  BattleTech.FactionsControllerTest.swift
//
//  Created by Richard Hancock on 2024-02-22.
//

@testable import App
import Fluent
import XCTVapor

final class RulesControllerTests: XCTestCase {
    var path = "/battletech/rules"

    func testIndex() async throws {
        let app = Application(.testing)
        defer { app.shutdown() }
        try await configureApp(app)

        _ = try await BattleTech.Rule.create(on: app.db(.primary))
        let ruleCount = try await BattleTech.Rule.query(on: app.db(.replica)).count()

        try app.test(.GET, path, afterResponse: { response in
            let rules = try response.content.decode([BattleTech.Rule].self)
            XCTAssertEqual(rules.count, ruleCount)
        })
    }

    func testShow() async throws {
        let app = Application(.testing)
        defer { app.shutdown() }
        try await configureApp(app)

        let rule = try await BattleTech.Rule.create(on: app.db(.primary))
        let showPath = "\(path)/\(rule.id!)"

        try app.test(.GET, showPath, afterResponse: { response in
            let returnedRule = try response.content.decode(BattleTech.Rule.self)
            XCTAssertEqual(rule.name, returnedRule.name)
        })
    }

    func testAmmo() async throws {
        let app = Application(.testing)
        defer { app.shutdown() }
        try await configureApp(app)

        let ammo = try await BattleTech.Ammo.create(on: app.db(.primary))
        try await ammo.$rules.load(on: app.db(.primary))
        let rule = ammo.rules.first!

        let showPath = "\(path)/\(rule.id!)/ammo"

        try app.test(.GET, showPath, afterResponse: { response in
            let returnedAmmo = try response.content.decode(Page<BattleTech.Ammo>.self)
            XCTAssertEqual(1, returnedAmmo.metadata.total)
        })
    }

    func testWeapons() async throws {
        let app = Application(.testing)
        defer { app.shutdown() }
        try await configureApp(app)

        let weapon = try await BattleTech.Weapon.create(on: app.db(.primary))
        try await weapon.$rules.load(on: app.db(.primary))
        let rule = weapon.rules.first!

        let showPath = "\(path)/\(rule.id!)/weapons"

        try app.test(.GET, showPath, afterResponse: { response in
            let returnedWeapons = try response.content.decode(Page<BattleTech.Weapon>.self)
            XCTAssertEqual(1, returnedWeapons.metadata.total)
        })
    }

    func testShowNotFound() async throws {
        let app = Application(.testing)
        defer { app.shutdown() }
        try await configureApp(app)

        let notFoundPath = "\(path)/NOT-A-UUID"

        try app.test(.GET, notFoundPath, afterResponse: { response in
            XCTAssertEqual(response.status, .notFound)
        })
    }

    private func configureApp(_ app: Application) async throws {
        try await configure(app)
        try await app.autoRevert()
        try await app.autoMigrate()
    }
}
