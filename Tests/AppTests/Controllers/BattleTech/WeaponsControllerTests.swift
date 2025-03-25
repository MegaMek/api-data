//
//  BattleTech.FactionsControllerTest.swift
//
//  Created by Richard Hancock on 2024-02-22.
//

import Fluent
import XCTVapor

@testable import App

final class WeaponsControllerTests: XCTestCase {
    var path = "/battletech/weapons"
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
        _ = try await BattleTech.Weapon.create(on: app.db)
        let weaponCount = try await BattleTech.Weapon.query(on: app.db).count()

        try app.test(
            .GET, path,
            loggedInRequest: false,
            afterResponse: { response in
                let weapons = try response.content.decode(Page<BattleTech.Weapon>.self)
                XCTAssertEqual(weapons.metadata.total, weaponCount)
            })
    }

    func testShow() async throws {
        let weapon = try await BattleTech.Weapon.create(on: app.db)
        let showPath = "\(path)/\(weapon.id!)"

        try app.test(
            .GET, showPath,
            loggedInRequest: false,
            afterResponse: { response in
                let returnedWeapon = try response.content.decode(BattleTech.Weapon.self)
                XCTAssertEqual(weapon.name, returnedWeapon.name)
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
        let weapon = try await BattleTech.Weapon.create(on: app.db)
        let showPath = "\(path)/\(weapon.id!)"

        try app.test(
            .DELETE, showPath,
            loggedInRequest: false,
            afterResponse: { response in
                XCTAssertEqual(response.status, .noContent)
            })
    }

    func testImport() async throws {
        let (testFileHandle, testFileRegion) = try await app.fileio.openFile(
            path: "Tests/Resources/BattleTech/weapons.csv",
            eventLoop: app.eventLoopGroup.next()
        ).get()

        let testFileByteBuffer = try await app.fileio.read(
            fileRegion: testFileRegion, allocator: .init())
        let weaponsMassImport = WeaponMassImport(
            file: File(data: testFileByteBuffer, filename: "weapons.csv"))
        try testFileHandle.close()

        let massImportPath = "\(path)/import"

        try app.test(
            .POST, massImportPath,
            loggedInRequest: false,
            beforeRequest: { request in
                try request.content.encode(weaponsMassImport)
            },
            afterResponse: { response in
                XCTAssertEqual(response.status, .created)
                XCTAssertNotNil(app.queues.queue.pop())
            })

        _ = app.redis.send(command: "FLUSHDB")
    }
}
