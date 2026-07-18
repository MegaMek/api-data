//
//  BattleTech.FactionsControllerTest.swift
//
//  Created by Richard Hancock on 2024-02-22.
//

import Fluent
import XCTVapor

@testable import App

final class EquipmentControllerTests: XCTestCase {
    var app: Application!
    var path = "/battletech/equipment"

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
        _ = try await BattleTech.Equipment.create(on: app.db)
        let equipmentCount = try await BattleTech.Equipment.query(on: app.db).count()

        try app.test(
            .GET, path,
            loggedInRequest: false,
            afterResponse: { response in
                let equipment = try response.content.decode(Page<BattleTech.Equipment>.self)
                XCTAssertEqual(equipment.metadata.total, equipmentCount)
            })
    }

    func testShow() async throws {
        let equipment = try await BattleTech.Equipment.create(on: app.db)
        let showPath = "\(path)/\(equipment.id!)"

        try app.test(
            .GET, showPath,
            loggedInRequest: false,
            afterResponse: { response in
                let returnedEquipment = try response.content.decode(BattleTech.Equipment.self)
                XCTAssertEqual(equipment.name, returnedEquipment.name)
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
        let equipment = try await BattleTech.Equipment.create(on: app.db)
        let showPath = "\(path)/\(equipment.id!)"

        try app.test(
            .DELETE, showPath,
            loggedInRequest: false,
            afterResponse: { response in
                XCTAssertEqual(response.status, .noContent)
            })
    }

    func testImport() async throws {
        let testFileByteBuffer = try await TestResources.buffer(for: "BattleTech/misc.csv")
        let equipmentMassImport = EquipmentMassImport(
            file: File(data: testFileByteBuffer, filename: "misc.csv"))

        let massImportPath = "\(path)/import"

        try app.test(
            .POST, massImportPath,
            loggedInRequest: false,
            beforeRequest: { request in
                try request.content.encode(equipmentMassImport)
            },
            afterResponse: { response in
                XCTAssertEqual(response.status, .created)
                XCTAssertNotNil(app.queues.queue.pop())
            })
    }
}
