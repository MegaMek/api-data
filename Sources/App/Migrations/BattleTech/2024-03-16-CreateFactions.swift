//
//  CreateFactions.swift
//
// Creates the Factions model based upon the XML from MegaMek
//
// Author: Richard J Hancock
// Date: 2024/03/16
//

import Fluent
import FluentSQL

extension BattleTech {
    struct CreateFactions: AsyncMigration {
        func prepare(on database: any Database) async throws {
            try await database.schema(for: BattleTech.Faction.self)
                .id()
                .field(BattleTech.Faction.V20240316.factionKey, .string, .required)
                .field(BattleTech.Faction.V20240316.minor, .bool, .required)
                .field(BattleTech.Faction.V20240316.clan, .bool, .required)
                .field(BattleTech.Faction.V20240316.periphery, .bool, .required)
                .field(BattleTech.Faction.V20240316.ratingLevels, .string, .required)

                .field(BattleTech.Faction.V20240316.publishedAt, .datetime)
                .field(BattleTech.Faction.V20240316.createdAt, .datetime)
                .field(BattleTech.Faction.V20240316.updatedAt, .datetime)

                .unique(on: BattleTech.Faction.V20240316.factionKey)
                .create()
        }

        func revert(on database: any Database) async throws {
            try await database.schema(for: BattleTech.Faction.self).delete()
        }
    }
}

extension BattleTech.Faction {
    enum V20240316 {
        static let schemaName = "factions"
        static let spaceName = "battletech"

        static let id = FieldKey(stringLiteral: "id")
        static let factionKey = FieldKey(stringLiteral: "faction_key")
        static let minor = FieldKey(stringLiteral: "minor")
        static let clan = FieldKey(stringLiteral: "clan")
        static let periphery = FieldKey(stringLiteral: "periphery")
        static let ratingLevels = FieldKey(stringLiteral: "ratingLevels")

        static let publishedAt = FieldKey(stringLiteral: "published_at")
        static let createdAt = FieldKey(stringLiteral: "created_at")
        static let updatedAt = FieldKey(stringLiteral: "updated_at")
    }
}
