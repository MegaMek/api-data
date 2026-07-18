/// CreateFactions.swift
///
/// Fluent migration that creates the `factions` table, storing BattleTech's playable factions
/// (e.g. House Davion, Clan Wolf), based on data sourced from MegaMek's XML.
///
/// Author: Richard J Hancock
/// Date: 2024/03/16

import Fluent
import FluentSQL

extension BattleTech {
    /// Creates the `factions` table.
    struct CreateFactions: AsyncMigration {
        /// Creates the `factions` table.
        /// - Parameter database: The database connection to apply the schema change to.
        /// - Throws: An error if the schema change fails.
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

        /// Drops the `factions` table.
        /// - Parameter database: The database connection to apply the schema change to.
        /// - Throws: An error if the schema change fails.
        func revert(on database: any Database) async throws {
            try await database.schema(for: BattleTech.Faction.self).delete()
        }
    }
}

extension BattleTech.Faction {
    /// Column-name constants (``FieldKey``s) for the `factions` table, version 2024-03-16.
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
