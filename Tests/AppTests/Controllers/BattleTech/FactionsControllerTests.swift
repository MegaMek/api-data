//
//  BattleTech.FactionsControllerTest.swift
//
//  Created by Richard Hancock on 2024-02-22.
//

import Fluent
import Testing
import VaporTesting

@testable import App

@Suite(.serialized, .databaseSerialized)
struct FactionsControllerTests {
    let path = "/battletech/factions"

    @Test
    func index() async throws {
        try await withTestApp { app in
            _ = try await BattleTech.Faction.create(on: app.db)
            let factionCount = try await BattleTech.Faction.query(on: app.db).count()

            try await app.test(
                .GET, path,
                loggedInRequest: false,
                afterResponse: { response in
                    let factions = try response.content.decode([BattleTech.Faction].self)
                    #expect(factions.count == factionCount)
                })
        }
    }

    @Test
    func show() async throws {
        try await withTestApp { app in
            let faction = try await BattleTech.Faction.create(on: app.db)
            let showPath = "\(path)/\(faction.id!)"

            try await app.test(
                .GET, showPath,
                loggedInRequest: false,
                afterResponse: { response in
                    let returnedFaction = try response.content.decode(BattleTech.Faction.self)
                    #expect(faction.factionKey == returnedFaction.factionKey)
                })
        }
    }

    @Test
    func showNotFound() async throws {
        try await withTestApp { app in
            let notFoundPath = "\(path)/NOT-A-UUID"

            try await app.test(
                .GET, notFoundPath,
                loggedInRequest: false,
                afterResponse: { response in
                    #expect(response.status == .notFound)
                })
        }
    }

    @Test
    func delete() async throws {
        try await withTestApp { app in
            let faction = try await BattleTech.Faction.create(on: app.db)
            let showPath = "\(path)/\(faction.id!)"

            try await app.test(
                .DELETE, showPath,
                loggedInRequest: false,
                afterResponse: { response in
                    #expect(response.status == .noContent)
                })
        }
    }

    @Test
    func `import`() async throws {
        try await withTestApp { app in
            let factionCount = try await BattleTech.Faction.query(on: app.db).count()

            let testFileByteBuffer = try await TestResources.buffer(for: "BattleTech/factions.xml")
            let factionMassImport = FactionMassImport(
                file: File(data: testFileByteBuffer, filename: "factions.xml"))

            let massImportPath = "\(path)/import"

            try await app.test(
                .POST, massImportPath,
                loggedInRequest: false,
                beforeRequest: { request in
                    try request.content.encode(factionMassImport)
                },
                afterResponse: { response in
                    #expect(response.status == .created)
                })

            let postFactionCount = try await BattleTech.Faction.query(on: app.db).count()
            #expect(factionCount != postFactionCount)
        }
    }

    @Test
    func duplicateImport() async throws {
        try await withTestApp { app in
            let testFileByteBuffer = try await TestResources.buffer(for: "BattleTech/factions.xml")
            let factionMassImport = FactionMassImport(
                file: File(data: testFileByteBuffer, filename: "factions.xml"))

            let massImportPath = "\(path)/import"

            try await app.test(
                .POST, massImportPath,
                loggedInRequest: false,
                beforeRequest: { request in
                    try request.content.encode(factionMassImport)
                },
                afterResponse: { response in
                    #expect(response.status == .created)
                })

            let factionCount = try await BattleTech.Faction.query(on: app.db).count()

            try await app.test(
                .POST, massImportPath,
                loggedInRequest: false,
                beforeRequest: { request in
                    try request.content.encode(factionMassImport)
                },
                afterResponse: { response in
                    let postCount = try await BattleTech.Faction.query(on: app.db).count()

                    #expect(response.status == .created)
                    #expect(factionCount == postCount)
                })
        }
    }
}
