//
//  BattleTech.FactionsControllerTest.swift
//
//  Created by Richard Hancock on 2024-02-22.
//

@testable import App
import Fluent
import XCTVapor

final class TechLevelControllerTests: XCTestCase {
    var path = "/battletech/tech-levels"

    func testIndex() async throws {
        let app = Application(.testing)
        defer { app.shutdown() }
        try await configureApp(app)

        _ = try await BattleTech.TechLevel.create(on: app.db(.primary))
        let techLevelCount = try await BattleTech.TechLevel.query(on: app.db(.replica)).count()

        try app.test(.GET, path, afterResponse: { response in
            let techLevels = try response.content.decode([BattleTech.TechLevel].self)
            XCTAssertEqual(techLevels.count, techLevelCount)
        })
    }

    func testShow() async throws {
        let app = Application(.testing)
        defer { app.shutdown() }
        try await configureApp(app)

        let techLevel = try await BattleTech.TechLevel.create(on: app.db(.primary))
        let showPath = "\(path)/\(techLevel.id!)"

        try app.test(.GET, showPath, afterResponse: { response in
            let returnedTechLevel = try response.content.decode(BattleTech.TechLevel.self)
            XCTAssertEqual(techLevel.name, returnedTechLevel.name)
        })
    }

    func testAmmo() async throws {
        let app = Application(.testing)
        defer { app.shutdown() }
        try await configureApp(app)

        let ammo = try await BattleTech.Ammo.create(on: app.db(.primary))
        let showPath = "\(path)/\(ammo.$techLevelStatic.id)/ammo"

        try app.test(.GET, showPath, afterResponse: { response in
            let returnedAmmo = try response.content.decode(Page<BattleTech.Ammo>.self)
            XCTAssertEqual(1, returnedAmmo.metadata.total)
        })
    }

    func testEquipment() async throws {
        let app = Application(.testing)
        defer { app.shutdown() }
        try await configureApp(app)

        let equipment = try await BattleTech.Equipment.create(on: app.db(.primary))
        let showPath = "\(path)/\(equipment.$techLevelStatic.id)/equipment"

        try app.test(.GET, showPath, afterResponse: { response in
            let returnedEquipment = try response.content.decode(Page<BattleTech.Equipment>.self)
            XCTAssertEqual(1, returnedEquipment.metadata.total)
        })
    }

    func testWeapons() async throws {
        let app = Application(.testing)
        defer { app.shutdown() }
        try await configureApp(app)

        let weapon = try await BattleTech.Weapon.create(on: app.db(.primary))
        let showPath = "\(path)/\(weapon.$techLevelStatic.id)/weapons"

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
