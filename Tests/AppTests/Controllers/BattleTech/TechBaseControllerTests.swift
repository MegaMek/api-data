//
//  BattleTech.FactionsControllerTest.swift
//
//  Created by Richard Hancock on 2024-02-22.
//

@testable import App
import Fluent
import XCTVapor

final class TechBaseControllerTests: XCTestCase {
    var path = "/battletech/tech-bases"

    func testIndex() async throws {
        let app = Application(.testing)
        defer { app.shutdown() }
        try await configureApp(app)

        _ = try await BattleTech.TechBase.create(on: app.db(.primary))
        let techBaseCount = try await BattleTech.TechBase.query(on: app.db(.replica)).count()

        try app.test(.GET, path, afterResponse: { response in
            let techBases = try response.content.decode([BattleTech.TechBase].self)
            XCTAssertEqual(techBases.count, techBaseCount)
        })
    }

    func testShow() async throws {
        let app = Application(.testing)
        defer { app.shutdown() }
        try await configureApp(app)

        let techBase = try await BattleTech.TechBase.create(on: app.db(.primary))
        let showPath = "\(path)/\(techBase.id!)"

        try app.test(.GET, showPath, afterResponse: { response in
            let returnedTechBase = try response.content.decode(BattleTech.TechBase.self)
            XCTAssertEqual(techBase.name, returnedTechBase.name)
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

    func testDelete() async throws {
        let app = Application(.testing)
        defer { app.shutdown() }
        try await configureApp(app)

        let techBase = try await BattleTech.TechBase.create(on: app.db(.primary))
        let showPath = "\(path)/\(techBase.id!)"

        try app.test(.DELETE, showPath, afterResponse: { response in
            XCTAssertEqual(response.status, .noContent)
        })
    }

    func testAmmo() async throws {
        let app = Application(.testing)
        defer { app.shutdown() }
        try await configureApp(app)

        let ammo = try await BattleTech.Ammo.create(on: app.db(.primary))
        let showPath = "\(path)/\(ammo.$techBase.id)/ammo"

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
        let showPath = "\(path)/\(equipment.$techBase.id)/equipment"

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
        let showPath = "\(path)/\(weapon.$techBase.id)/weapons"

        try app.test(.GET, showPath, afterResponse: { response in
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
