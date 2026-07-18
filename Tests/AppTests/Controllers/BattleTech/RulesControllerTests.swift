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
struct RulesControllerTests {
    let path = "/battletech/rules"

    @Test
    func index() async throws {
        try await withTestApp { app in
            _ = try await BattleTech.Rule.create(on: app.db)
            let ruleCount = try await BattleTech.Rule.query(on: app.db).count()

            try await app.test(
                .GET, path,
                loggedInRequest: false,
                afterResponse: { response in
                    let rules = try response.content.decode([BattleTech.Rule].self)
                    #expect(rules.count == ruleCount)
                })
        }
    }

    @Test
    func show() async throws {
        try await withTestApp { app in
            let rule = try await BattleTech.Rule.create(on: app.db)
            let showPath = "\(path)/\(rule.id!)"

            try await app.test(
                .GET, showPath,
                loggedInRequest: false,
                afterResponse: { response in
                    let returnedRule = try response.content.decode(BattleTech.Rule.self)
                    #expect(rule.name == returnedRule.name)
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
            let rule = try await BattleTech.Rule.create(on: app.db)
            let showPath = "\(path)/\(rule.id!)"

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
            try await ammo.$rules.load(on: app.db)
            let rule = ammo.rules.first!

            let showPath = "\(path)/\(rule.id!)/ammo"

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
            try await equipment.$rules.load(on: app.db)
            let rule = equipment.rules.first!

            let showPath = "\(path)/\(rule.id!)/equipment"

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
            try await weapon.$rules.load(on: app.db)
            let rule = weapon.rules.first!

            let showPath = "\(path)/\(rule.id!)/weapons"

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
