//
//  BattleTech.FactionsControllerTest.swift
//
//  Created by Richard Hancock on 2024-02-22.
//

@testable import App
import Fluent
import XCTVapor

final class AmmoControllerTests: XCTestCase {
    var path = "/battletech/ammo"

    func testIndex() async throws {
        let app = Application(.testing)
        defer { app.shutdown() }
        try await configureApp(app)

        _ = try await BattleTech.Ammo.create(on: app.db(.primary))
        let ammoCount = try await BattleTech.Ammo.query(on: app.db(.replica)).count()

        try app.test(.GET, path, afterResponse: { response in
            let ammo = try response.content.decode(Page<BattleTech.Ammo>.self)
            XCTAssertEqual(ammo.metadata.total, ammoCount)
        })
    }

    func testShow() async throws {
        let app = Application(.testing)
        defer { app.shutdown() }
        try await configureApp(app)

        let ammo = try await BattleTech.Ammo.create(on: app.db(.primary))
        let showPath = "\(path)/\(ammo.id!)"

        try app.test(.GET, showPath, afterResponse: { response in
            let returnedAmmo = try response.content.decode(BattleTech.Ammo.self)
            XCTAssertEqual(ammo.name, returnedAmmo.name)
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

        let ammo = try await BattleTech.Ammo.create(on: app.db(.primary))
        let showPath = "\(path)/\(ammo.id!)"

        try app.test(.DELETE, showPath, afterResponse: { response in
            XCTAssertEqual(response.status, .noContent)
        })
    }

    func testImport() async throws {
        let app = Application(.testing)
        defer { app.shutdown() }
        try await configureApp(app)

        let weaponCount = try await BattleTech.Ammo.query(on: app.db(.replica)).count()

        let (testFileHandle, testFileRegion) = try await app.fileio.openFile(
            path: "Tests/Resources/BattleTech/ammo.csv",
            eventLoop: app.eventLoopGroup.next()
        ).get()

        let testFileByteBuffer = try await app.fileio.read(fileRegion: testFileRegion, allocator: .init())
        let ammoMassImport = AmmoMassImport(file: File(data: testFileByteBuffer, filename: "ammo.csv"))
        try testFileHandle.close()

        let massImportPath = "\(path)/import"

        try await app.test(.POST, massImportPath, beforeRequest: { request in
            try request.content.encode(ammoMassImport)
        }, afterResponse: { response in
            XCTAssertEqual(response.status, .created)
            let postAmmoCount = try await BattleTech.Ammo.query(on: app.db(.replica)).count()
            XCTAssertNotEqual(weaponCount, postAmmoCount)
            XCTAssertEqual(30, postAmmoCount)
        })
    }

    func testDuplicateImport() async throws {
        let app = Application(.testing)
        defer { app.shutdown() }
        try await configureApp(app)

        let (testFileHandle, testFileRegion) = try await app.fileio.openFile(
            path: "Tests/Resources/BattleTech/ammo.csv",
            eventLoop: app.eventLoopGroup.next()
        ).get()

        let testFileByteBuffer = try await app.fileio.read(fileRegion: testFileRegion, allocator: .init())
        let ammoMassImport = AmmoMassImport(file: File(data: testFileByteBuffer, filename: "ammo.csv"))
        try testFileHandle.close()

        let massImportPath = "\(path)/import"

        try app.test(.POST, massImportPath, beforeRequest: { request in
            try request.content.encode(ammoMassImport)
        }, afterResponse: { response in
            XCTAssertEqual(response.status, .created)
        })

        let weaponCount = try await BattleTech.Ammo.query(on: app.db(.replica)).count()

        try await app.test(.POST, massImportPath, beforeRequest: { request in
            try request.content.encode(ammoMassImport)
        }, afterResponse: { response in
            let postCount = try await BattleTech.Ammo.query(on: app.db(.replica)).count()

            XCTAssertEqual(response.status, .created)
            XCTAssertEqual(weaponCount, postCount)
        })
    }

    private func configureApp(_ app: Application) async throws {
        try await configure(app)
        try await app.autoRevert()
        try await app.autoMigrate()
    }
}
