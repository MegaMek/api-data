//
//  BattleTech+Testable Extension.swift
//
//  Extensions to BattleTech models for testing
//
//  Created by Richard Hancock on 2024-02-22.
//

@testable import App
import Fluent
import Vapor

extension BattleTech.Era {
    static func create(
        code: String = "TEST",
        name: String = "Test Era",
        endYear: Int = 9999,
        flag: String = "TEST_FLAG",
        icon: String = "test.png",
        mulId: Int = -1,
        on database: any Database
    ) async throws -> BattleTech.Era {
        let era = BattleTech.Era(
          code: code,
          name: name,
          endYear: endYear,
          flag: flag,
          icon: icon,
          mulId: mulId
        )

        try await era.save(on: database)
        return era
    }
}

extension BattleTech.Faction {
    static func create(
        factionKey: String = "TST",
        ratingLevels: String = "",
        on database: any Database
    ) async throws -> BattleTech.Faction {
        let faction = BattleTech.Faction(factionKey: factionKey, ratingLevels: ratingLevels)

        try await faction.save(on: database)
        return faction
    }
}

extension BattleTech.TechBase {
    static func create(
        name: String = "Test Tech Base",
        on database: any Database
    ) async throws -> BattleTech.TechBase {
        let techBase = BattleTech.TechBase(name: name)

        try await techBase.save(on: database)
        return techBase
    }
}

extension BattleTech.TechLevel {
    static func create(
        name: String = "Test Tech Level",
        on database: any Database
    ) async throws -> BattleTech.TechLevel {
        let techLevel = BattleTech.TechLevel(name: name)

        try await techLevel.save(on: database)
        return techLevel
    }
}
extension BattleTech.Weapon {
    static func create(
        name: String = "Test Weapon",
        on database: any Database
    ) async throws -> BattleTech.Weapon {
        let techBase = try await BattleTech.TechBase.create(name: "Test Weapon Base", on: database)
        let techLevel = try await BattleTech.TechLevel.create(name: "Test Weapon Level", on: database)

        let weapon = BattleTech.Weapon(
            name: name,
            techBase: techBase,
            techRating: "X/A-A-A-A",
            techLevelStatic: techLevel,
            introductionDate: "2024",
            prototypeDate: "2025",
            productionDate: "2026",
            commonDate: "2027",
            extinctionDate: "2028",
            reIntroductionDate: "2029",
            tonnage: 1.0,
            criticalSlots: 1,
            cost: 1.0,
            battleValue: 1.0,
            rulesReference: "TST p24",
            minimalRange: 0,
            shortRange: 0,
            mediumRange: 0,
            longRange: 0,
            extremeRange: 0,
            shortWaterRange: 0,
            mediumWaterRange: 0,
            longWaterRange: 0,
            extremeWaterRange: 0,
            minimalRangeDamage: 0,
            shortRangeDamage: 0,
            mediumRangeDamage: 0,
            longRangeDamage: 0,
            extremeRangeDamage: 0
        )

        try await weapon.save(on: database)
        return weapon
    }
}
