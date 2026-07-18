//
//  BattleTech.ErasControllerTest.swift
//
//  Created by Richard Hancock on 2024-02-22.
//

import Fluent
import Testing
import VaporTesting

@testable import App

@Suite(.serialized, .databaseSerialized)
struct ErasControllerTests {
    let path = "/battletech/eras"

    @Test
    func index() async throws {
        try await withTestApp { app in
            _ = try await BattleTech.Era.create(on: app.db)
            let eraCount = try await BattleTech.Era.query(on: app.db).count()

            try await app.test(
                .GET, path,
                loggedInRequest: false,
                afterResponse: { response in
                    let eras = try response.content.decode([BattleTech.Era].self)
                    #expect(eras.count == eraCount)
                })
        }
    }

    @Test
    func show() async throws {
        try await withTestApp { app in
            let era = try await BattleTech.Era.create(on: app.db)
            let showPath = "\(path)/\(era.id!)"

            try await app.test(
                .GET, showPath,
                loggedInRequest: false,
                afterResponse: { response in
                    let returnedEra = try response.content.decode(BattleTech.Era.self)
                    #expect(era.name == returnedEra.name)
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
            let era = try await BattleTech.Era.create(on: app.db)
            let showPath = "\(path)/\(era.id!)"

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
            let eraCount = try await BattleTech.Era.query(on: app.db).count()

            let testFileByteBuffer = try await TestResources.buffer(for: "BattleTech/eras.xml")
            let eraMassImport = EraMassImport(
                file: File(data: testFileByteBuffer, filename: "eras.xml"))

            let massImportPath = "\(path)/import"

            try await app.test(
                .POST, massImportPath,
                loggedInRequest: false,
                beforeRequest: { request in
                    try request.content.encode(eraMassImport)
                },
                afterResponse: { response in
                    #expect(response.status == .created)
                })

            let postEraCount = try await BattleTech.Era.query(on: app.db).count()
            #expect(eraCount != postEraCount)
        }
    }

    @Test
    func duplicateImport() async throws {
        try await withTestApp { app in
            let testFileByteBuffer = try await TestResources.buffer(for: "BattleTech/eras.xml")
            let eraMassImport = EraMassImport(
                file: File(data: testFileByteBuffer, filename: "eras.xml"))

            let massImportPath = "\(path)/import"

            try await app.test(
                .POST, massImportPath,
                loggedInRequest: false,
                beforeRequest: { request in
                    try request.content.encode(eraMassImport)
                },
                afterResponse: { response in
                    #expect(response.status == .created)
                })

            let eraCount = try await BattleTech.Era.query(on: app.db).count()

            try await app.test(
                .POST, massImportPath,
                loggedInRequest: false,
                beforeRequest: { request in
                    try request.content.encode(eraMassImport)
                },
                afterResponse: { response in
                    let postCount = try await BattleTech.Era.query(on: app.db).count()

                    #expect(response.status == .created)
                    #expect(eraCount == postCount)
                })
        }
    }
}
