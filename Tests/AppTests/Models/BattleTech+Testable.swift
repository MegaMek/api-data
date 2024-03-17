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
