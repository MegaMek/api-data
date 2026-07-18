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
struct TechBaseControllerTests {
    let path = "/battletech/tech-bases"

    @Test
    func index() async throws {
        try await withTestApp { app in
            _ = try await BattleTech.TechBase.create(on: app.db)
            let techBaseCount = try await BattleTech.TechBase.query(on: app.db).count()

            try await app.test(
                .GET, path,
                loggedInRequest: false,
                afterResponse: { response in
                    let techBases = try response.content.decode([BattleTech.TechBase].self)
                    #expect(techBases.count == techBaseCount)
                })
        }
    }

    @Test
    func show() async throws {
        try await withTestApp { app in
            let techBase = try await BattleTech.TechBase.create(on: app.db)
            let showPath = "\(path)/\(techBase.id!)"

            try await app.test(
                .GET, showPath,
                loggedInRequest: false,
                afterResponse: { response in
                    let returnedTechBase = try response.content.decode(BattleTech.TechBase.self)
                    #expect(techBase.name == returnedTechBase.name)
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
            let techBase = try await BattleTech.TechBase.create(on: app.db)
            let showPath = "\(path)/\(techBase.id!)"

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
            let showPath = "\(path)/\(ammo.$techBase.id)/ammo"

            try await app.test(
                .GET, showPath,
                loggedInRequest: false,
                afterResponse: { response in
                    let returnedAmmo = try response.content.decode(Page<BattleTech.Ammo>.self)
                    #expect(1 == returnedAmmo.metadata.total)
                })
        }
    }

    @Test
    func equipment() async throws {
        try await withTestApp { app in
            let equipment = try await BattleTech.Equipment.create(on: app.db)
            let showPath = "\(path)/\(equipment.$techBase.id)/equipment"

            try await app.test(
                .GET, showPath,
                loggedInRequest: false,
                afterResponse: { response in
                    let returnedEquipment = try response.content.decode(Page<BattleTech.Equipment>.self)
                    #expect(1 == returnedEquipment.metadata.total)
                })
        }
    }

    @Test
    func weapons() async throws {
        try await withTestApp { app in
            let weapon = try await BattleTech.Weapon.create(on: app.db)
            let showPath = "\(path)/\(weapon.$techBase.id)/weapons"

            try await app.test(
                .GET, showPath,
                loggedInRequest: false,
                afterResponse: { response in
                    let returnedWeapons = try response.content.decode(Page<BattleTech.Weapon>.self)
                    #expect(1 == returnedWeapons.metadata.total)
                })
        }
    }
}
