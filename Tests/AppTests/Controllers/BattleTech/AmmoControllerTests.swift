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
struct AmmoControllerTests {
    let path = "/battletech/ammo"

    @Test
    func index() async throws {
        try await withTestApp { app in
            _ = try await BattleTech.Ammo.create(on: app.db)
            let ammoCount = try await BattleTech.Ammo.query(on: app.db).count()

            try await app.test(
                .GET, path,
                loggedInRequest: false,
                afterResponse: { response in
                    let ammo = try response.content.decode(Page<BattleTech.Ammo>.self)
                    #expect(ammo.metadata.total == ammoCount)
                })
        }
    }

    @Test
    func show() async throws {
        try await withTestApp { app in
            let ammo = try await BattleTech.Ammo.create(on: app.db)
            let showPath = "\(path)/\(ammo.id!)"

            try await app.test(
                .GET, showPath,
                loggedInRequest: false,
                afterResponse: { response in
                    let returnedAmmo = try response.content.decode(BattleTech.Ammo.self)
                    #expect(ammo.name == returnedAmmo.name)
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
            let ammo = try await BattleTech.Ammo.create(on: app.db)
            let showPath = "\(path)/\(ammo.id!)"

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
            let testFileByteBuffer = try await TestResources.buffer(for: "BattleTech/ammo.csv")
            let ammoMassImport = AmmoMassImport(
                file: File(data: testFileByteBuffer, filename: "ammo.csv"))

            let massImportPath = "\(path)/import"

            try await app.test(
                .POST, massImportPath,
                loggedInRequest: false,
                beforeRequest: { request in
                    try request.content.encode(ammoMassImport)
                },
                afterResponse: { response in
                    #expect(response.status == .created)
                    #expect(app.queues.queue.pop() != nil)
                })
        }
    }
}
