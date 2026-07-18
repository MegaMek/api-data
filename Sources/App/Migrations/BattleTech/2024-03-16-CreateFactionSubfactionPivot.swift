/// CreateFactionSubfactionPivot.swift
///
/// Fluent migration that creates the `faction_subfaction_pivot` table, the many-to-many join
/// table linking a faction to the other factions that are its sub-factions.
///
/// Author: Richard J Hancock
/// Date: 2024/03/16

import Fluent
import FluentSQL

extension BattleTech {
    /// Creates the `faction_subfaction_pivot` table.
    ///
    /// A "pivot" migration creates a join table for a many-to-many relationship instead of a
    /// table for a standalone model — here, between factions and their sub-factions. Both
    /// foreign keys reference `factions.id` since a sub-faction is itself a ``BattleTech/Faction``.
    struct CreateFactionSubfactionPivot: AsyncMigration {
        /// Creates the `faction_subfaction_pivot` table.
        /// - Parameter database: The database connection to apply the schema change to.
        /// - Throws: An error if the schema change fails.
        func prepare(on database: any Database) async throws {
            try await database.schema(for: BattleTech.FactionSubfactionPivot.self)
                .id()
                .field(
                    BattleTech.FactionSubfactionPivot.V20240316.faction,
                    .uuid,
                    .references(BattleTech.Faction.self, BattleTech.Faction.V20240316.id, onDelete: .cascade)
                )
                .field(
                    BattleTech.FactionSubfactionPivot.V20240316.subfaction,
                    .uuid,
                    .references(BattleTech.Faction.self, BattleTech.Faction.V20240316.id, onDelete: .cascade)
                )
                .unique(
                    on:
                        BattleTech.FactionSubfactionPivot.V20240316.faction,
                    BattleTech.FactionSubfactionPivot.V20240316.subfaction
                )
                .create()
        }

        /// Drops the `faction_subfaction_pivot` table.
        /// - Parameter database: The database connection to apply the schema change to.
        /// - Throws: An error if the schema change fails.
        func revert(on database: any Database) async throws {
            try await database.schema(for: BattleTech.FactionSubfactionPivot.self).delete()
        }
    }
}

extension BattleTech.FactionSubfactionPivot {
    /// Column-name constants (``FieldKey``s) for the `faction_subfaction_pivot` table, version
    /// 2024-03-16.
    enum V20240316 {
        static let schemaName = "faction_subfaction_pivot"
        static let spaceName = "battletech"

        static let id = FieldKey(stringLiteral: "id")
        static let faction = FieldKey(stringLiteral: "faction_id")
        static let subfaction = FieldKey(stringLiteral: "subfaction_id")
    }
}
