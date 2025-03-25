//
//  BattleTech.FactionsControllerTest.swift
//
//  Created by Richard Hancock on 2024-02-22.
//

import Fluent
import XCTVapor

@testable import App

final class TechLevelControllerTests: XCTestCase {
    var path = "/battletech/tech-levels"
    var app: Application!

    override func setUp() async throws {
        self.app = try await Application.make(.testing)
        try await configure(app)
        try await app.autoMigrate()
    }

    override func tearDown() async throws {
        try await app.autoRevert()
        try await self.app.asyncShutdown()
        self.app = nil
    }

    func testIndex() async throws {
        _ = try await BattleTech.TechLevel.create(on: app.db)
        let techLevelCount = try await BattleTech.TechLevel.query(on: app.db).count()

        try app.test(
            .GET, path,
            loggedInRequest: false,
            afterResponse: { response in
                let techLevels = try response.content.decode([BattleTech.TechLevel].self)
                XCTAssertEqual(techLevels.count, techLevelCount)
            })
    }

    func testShow() async throws {
        let techLevel = try await BattleTech.TechLevel.create(on: app.db)
        let showPath = "\(path)/\(techLevel.id!)"

        try app.test(
            .GET, showPath,
            loggedInRequest: false,
            afterResponse: { response in
                let returnedTechLevel = try response.content.decode(BattleTech.TechLevel.self)
                XCTAssertEqual(techLevel.name, returnedTechLevel.name)
            })
    }

    func testShowNotFound() async throws {
        let notFoundPath = "\(path)/NOT-A-UUID"

        try app.test(
            .GET, notFoundPath,
            loggedInRequest: false,
            afterResponse: { response in
                XCTAssertEqual(response.status, .notFound)
            })
    }

    func testDelete() async throws {
        let techLevel = try await BattleTech.TechLevel.create(on: app.db)
        let showPath = "\(path)/\(techLevel.id!)"

        try app.test(
            .DELETE, showPath,
            loggedInRequest: false,
            afterResponse: { response in
                XCTAssertEqual(response.status, .noContent)
            })
    }

    func testAmmo() async throws {
        let ammo = try await BattleTech.Ammo.create(on: app.db)
        let showPath = "\(path)/\(ammo.$techLevelStatic.id)/ammo"

        try app.test(
            .GET, showPath,
            loggedInRequest: false,
            afterResponse: { response in
                let returnedAmmo = try response.content.decode(Page<BattleTech.Ammo>.self)
                XCTAssertEqual(1, returnedAmmo.metadata.total)
            })
    }

    func testEquipment() async throws {
        let equipment = try await BattleTech.Equipment.create(on: app.db)
        let showPath = "\(path)/\(equipment.$techLevelStatic.id)/equipment"

        try app.test(
            .GET, showPath,
            loggedInRequest: false,
            afterResponse: { response in
                let returnedEquipment = try response.content.decode(Page<BattleTech.Equipment>.self)
                XCTAssertEqual(1, returnedEquipment.metadata.total)
            })
    }

    func testWeapons() async throws {
        let weapon = try await BattleTech.Weapon.create(on: app.db)
        let showPath = "\(path)/\(weapon.$techLevelStatic.id)/weapons"

        try app.test(
            .GET, showPath,
            loggedInRequest: false,
            afterResponse: { response in
                let returnedWeapons = try response.content.decode(Page<BattleTech.Weapon>.self)
                XCTAssertEqual(1, returnedWeapons.metadata.total)
            })
    }
}
