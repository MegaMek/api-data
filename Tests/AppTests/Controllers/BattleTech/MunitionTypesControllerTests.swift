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
struct MunitionTypesControllerTests {
    let path = "/battletech/munition-types"

    @Test
    func index() async throws {
        try await withTestApp { app in
            _ = try await BattleTech.MunitionType.create(on: app.db)
            let munitionTypeCount = try await BattleTech.MunitionType.query(on: app.db).count()

            try await app.test(
                .GET, path,
                loggedInRequest: false,
                afterResponse: { response in
                    let munitionTypes = try response.content.decode([BattleTech.MunitionType].self)
                    #expect(munitionTypes.count == munitionTypeCount)
                })
        }
    }

    @Test
    func show() async throws {
        try await withTestApp { app in
            let munitionType = try await BattleTech.MunitionType.create(on: app.db)
            let showPath = "\(path)/\(munitionType.id!)"

            try await app.test(
                .GET, showPath,
                loggedInRequest: false,
                afterResponse: { response in
                    let returnedMunitionType = try response.content.decode(BattleTech.MunitionType.self)
                    #expect(munitionType.name == returnedMunitionType.name)
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
            let munitionType = try await BattleTech.MunitionType.create(on: app.db)
            let showPath = "\(path)/\(munitionType.id!)"

            try await app.test(
                .DELETE, showPath,
                loggedInRequest: false,
                afterResponse: { response in
                    #expect(response.status == .noContent)
                })
        }
    }

    @Test
    func ammo() async throws {
        try await withTestApp { app in
            let ammo = try await BattleTech.Ammo.create(on: app.db)
            let showPath = "\(path)/\(ammo.$munitionType.id)/ammo"

            try await app.test(
                .GET, showPath,
                loggedInRequest: false,
                afterResponse: { response in
                    let returnedAmmo = try response.content.decode(Page<BattleTech.Ammo>.self)
                    #expect(1 == returnedAmmo.metadata.total)
                })
        }
    }
}
