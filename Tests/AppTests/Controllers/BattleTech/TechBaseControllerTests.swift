//
//  BattleTech.FactionsControllerTest.swift
//
//  Created by Richard Hancock on 2024-02-22.
//

import Fluent
import XCTVapor

@testable import App

final class TechBaseControllerTests: XCTestCase {
    var path = "/battletech/tech-bases"
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
        _ = try await BattleTech.TechBase.create(on: app.db)
        let techBaseCount = try await BattleTech.TechBase.query(on: app.db).count()

        try app.test(
            .GET, path,
            loggedInRequest: false,
            afterResponse: { response in
                let techBases = try response.content.decode([BattleTech.TechBase].self)
                XCTAssertEqual(techBases.count, techBaseCount)
            })
    }

    func testShow() async throws {
        let techBase = try await BattleTech.TechBase.create(on: app.db)
        let showPath = "\(path)/\(techBase.id!)"

        try app.test(
            .GET, showPath,
            loggedInRequest: false,
            afterResponse: { response in
                let returnedTechBase = try response.content.decode(BattleTech.TechBase.self)
                XCTAssertEqual(techBase.name, returnedTechBase.name)
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
        let techBase = try await BattleTech.TechBase.create(on: app.db)
        let showPath = "\(path)/\(techBase.id!)"

        try app.test(
            .DELETE, showPath,
            loggedInRequest: false,
            afterResponse: { response in
                XCTAssertEqual(response.status, .noContent)
            })
    }

    func testAmmo() async throws {
        let ammo = try await BattleTech.Ammo.create(on: app.db)
        let showPath = "\(path)/\(ammo.$techBase.id)/ammo"

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
        let showPath = "\(path)/\(equipment.$techBase.id)/equipment"

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
        let showPath = "\(path)/\(weapon.$techBase.id)/weapons"

        try app.test(
            .GET, showPath,
            loggedInRequest: false,
            afterResponse: { response in
                let returnedWeapons = try response.content.decode(Page<BattleTech.Weapon>.self)
                XCTAssertEqual(1, returnedWeapons.metadata.total)
            })
    }
}
