/// CreateFactionNames.swift
///
/// Fluent migration that creates the `faction_names` table, storing the (possibly multiple,
/// date-ranged) names a faction has used over BattleTech's history, based on data sourced from
/// MegaMek's XML.
///
/// Author: Richard J Hancock
/// Date: 2024/03/16

import Fluent
import FluentSQL

extension BattleTech {
    /// Creates the `faction_names` table, which references `factions` via a `faction_id`
    /// foreign key.
    ///
    /// Like every migration in this directory, this is a Fluent ``AsyncMigration``:
    /// ``prepare(on:)`` applies the schema change and ``revert(on:)`` undoes it. Fluent tracks
    /// which migrations have already run so each applies at most once.
    struct CreateFactionNames: AsyncMigration {
        /// Creates the `faction_names` table.
        /// - Parameter database: The database connection to apply the schema change to.
        /// - Throws: An error if the schema change fails.
        func prepare(on database: any Database) async throws {
            try await database.schema(for: BattleTech.FactionName.self)
                .id()
                .field(BattleTech.FactionName.V20240316.name, .string, .required)
                .field(BattleTech.FactionName.V20240316.startYear, .int)
                .field(BattleTech.FactionName.V20240316.endYear, .int)
                .field(
                    BattleTech.FactionName.V20240316.faction,
                    .uuid,
                    .references(BattleTech.Faction.self, BattleTech.Faction.V20240316.id)
                )
                .unique(
                    on:
                        BattleTech.FactionName.V20240316.faction,
                    BattleTech.FactionName.V20240316.name,
                    BattleTech.FactionName.V20240316.startYear
                )
                .create()
        }

        /// Drops the `faction_names` table.
        /// - Parameter database: The database connection to apply the schema change to.
        /// - Throws: An error if the schema change fails.
        func revert(on database: any Database) async throws {
            try await database.schema(for: BattleTech.FactionName.self).delete()
        }
    }
}

extension BattleTech.FactionName {
    /// Column-name constants (``FieldKey``s) for the `faction_names` table as of the
    /// 2024-03-16 schema version — a stable, versioned record of column names independent of
    /// the Swift property names on ``BattleTech/FactionName``.
    enum V20240316 {
        static let schemaName = "faction_names"
        static let spaceName = "battletech"

        static let id = FieldKey(stringLiteral: "id")
        static let name = FieldKey(stringLiteral: "name")
        static let startYear = FieldKey(stringLiteral: "start_year")
        static let endYear = FieldKey(stringLiteral: "end_year")
        static let faction = FieldKey(stringLiteral: "faction_id")
    }
}
