//
//  CreateFactionSubfactionPivot.swift
//
// Creates the Factions model based upon the XML from MegaMek
//
// Author: Richard J Hancock
// Date: 2024/03/16
//

import Fluent
import FluentSQL

extension BattleTech {
    struct CreateFactionSubfactionPivot: AsyncMigration {
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

        func revert(on database: any Database) async throws {
            try await database.schema(for: BattleTech.FactionSubfactionPivot.self).delete()
        }
    }
}

extension BattleTech.FactionSubfactionPivot {
    enum V20240316 {
        static let schemaName = "faction_subfaction_pivot"
        static let spaceName = "battletech"

        static let id = FieldKey(stringLiteral: "id")
        static let faction = FieldKey(stringLiteral: "faction_id")
        static let subfaction = FieldKey(stringLiteral: "subfaction_id")
    }
}
