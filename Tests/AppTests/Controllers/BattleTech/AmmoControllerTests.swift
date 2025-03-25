//
//  BattleTech.FactionsControllerTest.swift
//
//  Created by Richard Hancock on 2024-02-22.
//

import Fluent
import XCTVapor

@testable import App

final class AmmoControllerTests: XCTestCase {
    var path = "/battletech/ammo"
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
        _ = try await BattleTech.Ammo.create(on: app.db(.primary))
        let ammoCount = try await BattleTech.Ammo.query(on: app.db(.replica)).count()

        try app.test(
            .GET, path,
            loggedInRequest: false,
            afterResponse: { response in
                let ammo = try response.content.decode(Page<BattleTech.Ammo>.self)
                XCTAssertEqual(ammo.metadata.total, ammoCount)
            })
    }

    func testShow() async throws {
        let ammo = try await BattleTech.Ammo.create(on: app.db(.primary))
        let showPath = "\(path)/\(ammo.id!)"

        try app.test(
            .GET, showPath,
            loggedInRequest: false,
            afterResponse: { response in
                let returnedAmmo = try response.content.decode(BattleTech.Ammo.self)
                XCTAssertEqual(ammo.name, returnedAmmo.name)
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
        let ammo = try await BattleTech.Ammo.create(on: app.db(.primary))
        let showPath = "\(path)/\(ammo.id!)"

        try app.test(
            .DELETE, showPath,
            loggedInRequest: false,
            afterResponse: { response in
                XCTAssertEqual(response.status, .noContent)
            })
    }

    func testImport() async throws {
        let (testFileHandle, testFileRegion) = try await app.fileio.openFile(
            path: "Tests/Resources/BattleTech/ammo.csv",
            eventLoop: app.eventLoopGroup.next()
        ).get()

        let testFileByteBuffer = try await app.fileio.read(
            fileRegion: testFileRegion, allocator: .init())
        let ammoMassImport = AmmoMassImport(file: File(data: testFileByteBuffer, filename: "ammo.csv"))
        try testFileHandle.close()

        let massImportPath = "\(path)/import"

        try app.test(
            .POST, massImportPath,
            loggedInRequest: false,
            beforeRequest: { request in
                try request.content.encode(ammoMassImport)
            },
            afterResponse: { response in
                XCTAssertEqual(response.status, .created)
                XCTAssertNotNil(app.queues.queue.pop())
            })

        _ = app.redis.send(command: "FLUSHDB")
    }
}
