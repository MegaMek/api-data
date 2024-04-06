//
//  BattleTech.FactionsControllerTest.swift
//
//  Created by Richard Hancock on 2024-02-22.
//

@testable import App
import Fluent
import XCTVapor

final class EquipmentControllerTests: XCTestCase {
    var path = "/battletech/equipment"

    func testIndex() async throws {
        let app = Application(.testing)
        defer { app.shutdown() }
        try await configureApp(app)

        _ = try await BattleTech.Equipment.create(on: app.db(.primary))
        let equipmentCount = try await BattleTech.Equipment.query(on: app.db(.replica)).count()

        try app.test(.GET, path, afterResponse: { response in
            let equipment = try response.content.decode(Page<BattleTech.Equipment>.self)
            XCTAssertEqual(equipment.metadata.total, equipmentCount)
        })
    }

    func testShow() async throws {
        let app = Application(.testing)
        defer { app.shutdown() }
        try await configureApp(app)

        let equipment = try await BattleTech.Equipment.create(on: app.db(.primary))
        let showPath = "\(path)/\(equipment.id!)"

        try app.test(.GET, showPath, afterResponse: { response in
            let returnedEquipment = try response.content.decode(BattleTech.Equipment.self)
            XCTAssertEqual(equipment.name, returnedEquipment.name)
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

        let equipment = try await BattleTech.Equipment.create(on: app.db(.primary))
        let showPath = "\(path)/\(equipment.id!)"

        try app.test(.DELETE, showPath, afterResponse: { response in
            XCTAssertEqual(response.status, .noContent)
        })
    }

    func testImport() async throws {
        let app = Application(.testing)
        defer { app.shutdown() }
        try await configureApp(app)

        let equipmentCount = try await BattleTech.Equipment.query(on: app.db(.replica)).count()

        let (testFileHandle, testFileRegion) = try await app.fileio.openFile(
            path: "Tests/Resources/BattleTech/misc.csv",
            eventLoop: app.eventLoopGroup.next()
        ).get()

        let testFileByteBuffer = try await app.fileio.read(fileRegion: testFileRegion, allocator: .init())
        let equipmentMassImport = EquipmentMassImport(file: File(data: testFileByteBuffer, filename: "misc.csv"))
        try testFileHandle.close()

        let massImportPath = "\(path)/import"

        try await app.test(.POST, massImportPath, beforeRequest: { request in
            try request.content.encode(equipmentMassImport)
        }, afterResponse: { response in
            XCTAssertEqual(response.status, .created)
            let postEquipmentCount = try await BattleTech.Equipment.query(on: app.db(.replica)).count()
            XCTAssertNotEqual(equipmentCount, postEquipmentCount)
            XCTAssertEqual(35, postEquipmentCount)
        })
    }

    func testDuplicateImport() async throws {
        let app = Application(.testing)
        defer { app.shutdown() }
        try await configureApp(app)

        let (testFileHandle, testFileRegion) = try await app.fileio.openFile(
            path: "Tests/Resources/BattleTech/misc.csv",
            eventLoop: app.eventLoopGroup.next()
        ).get()

        let testFileByteBuffer = try await app.fileio.read(fileRegion: testFileRegion, allocator: .init())
        let equipmentMassImport = EquipmentMassImport(file: File(data: testFileByteBuffer, filename: "misc.csv"))
        try testFileHandle.close()

        let massImportPath = "\(path)/import"

        try app.test(.POST, massImportPath, beforeRequest: { request in
            try request.content.encode(equipmentMassImport)
        }, afterResponse: { response in
            XCTAssertEqual(response.status, .created)
        })

        let equipmentCount = try await BattleTech.Equipment.query(on: app.db(.replica)).count()

        try await app.test(.POST, massImportPath, beforeRequest: { request in
            try request.content.encode(equipmentMassImport)
        }, afterResponse: { response in
            let postCount = try await BattleTech.Equipment.query(on: app.db(.replica)).count()

            XCTAssertEqual(response.status, .created)
            XCTAssertEqual(equipmentCount, postCount)
        })
    }

    private func configureApp(_ app: Application) async throws {
        try await configure(app)
        try await app.autoRevert()
        try await app.autoMigrate()
    }
}
