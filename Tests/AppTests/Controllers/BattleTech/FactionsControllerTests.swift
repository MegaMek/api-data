//
//  BattleTech.FactionsControllerTest.swift
//
//  Created by Richard Hancock on 2024-02-22.
//

import Fluent
import XCTVapor

@testable import App

final class FactionsControllerTests: XCTestCase {
    var app: Application!
    var path = "/battletech/factions"

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
        _ = try await BattleTech.Faction.create(on: app.db)
        let factionCount = try await BattleTech.Faction.query(on: app.db).count()

        try app.test(
            .GET, path,
            loggedInRequest: false,
            afterResponse: { response in
                let factions = try response.content.decode([BattleTech.Faction].self)
                XCTAssertEqual(factions.count, factionCount)
            })
    }

    func testShow() async throws {
        let faction = try await BattleTech.Faction.create(on: app.db)
        let showPath = "\(path)/\(faction.id!)"

        try app.test(
            .GET, showPath,
            loggedInRequest: false,
            afterResponse: { response in
                let returnedFaction = try response.content.decode(BattleTech.Faction.self)
                XCTAssertEqual(faction.factionKey, returnedFaction.factionKey)
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
        let faction = try await BattleTech.Faction.create(on: app.db)
        let showPath = "\(path)/\(faction.id!)"

        try app.test(
            .DELETE, showPath,
            loggedInRequest: false,
            afterResponse: { response in
                XCTAssertEqual(response.status, .noContent)
            })
    }

    func testImport() async throws {
        let factionCount = try await BattleTech.Faction.query(on: app.db).count()

        let (testFileHandle, testFileRegion) = try await app.fileio.openFile(
            path: "Tests/Resources/BattleTech/factions.xml",
            eventLoop: app.eventLoopGroup.next()
        ).get()

        let testFileByteBuffer = try await app.fileio.read(
            fileRegion: testFileRegion, allocator: .init())
        let factionMassImport = FactionMassImport(
            file: File(data: testFileByteBuffer, filename: "factions.xml"))
        try testFileHandle.close()

        let massImportPath = "\(path)/import"

        try app.test(
            .POST, massImportPath,
            loggedInRequest: false,
            beforeRequest: { request in
                try request.content.encode(factionMassImport)
            },
            afterResponse: { response in
                XCTAssertEqual(response.status, .created)
            })

        let postFactionCount = try await BattleTech.Faction.query(on: app.db).count()
        XCTAssertNotEqual(factionCount, postFactionCount)
    }

    func testDuplicateImport() async throws {
        let (testFileHandle, testFileRegion) = try await app.fileio.openFile(
            path: "Tests/Resources/BattleTech/factions.xml",
            eventLoop: app.eventLoopGroup.next()
        ).get()

        let testFileByteBuffer = try await app.fileio.read(
            fileRegion: testFileRegion, allocator: .init())
        let factionMassImport = FactionMassImport(
            file: File(data: testFileByteBuffer, filename: "factions.xml"))
        try testFileHandle.close()

        let massImportPath = "\(path)/import"

        try app.test(
            .POST, massImportPath,
            loggedInRequest: false,
            beforeRequest: { request in
                try request.content.encode(factionMassImport)
            },
            afterResponse: { response in
                XCTAssertEqual(response.status, .created)
            })

        let factionCount = try await BattleTech.Faction.query(on: app.db).count()

        try await app.test(
            .POST, massImportPath,
            beforeRequest: { request in
                try request.content.encode(factionMassImport)
            },
            afterResponse: { response in
                let postCount = try await BattleTech.Faction.query(on: app.db).count()

                XCTAssertEqual(response.status, .created)
                XCTAssertEqual(factionCount, postCount)
            })
    }
}
