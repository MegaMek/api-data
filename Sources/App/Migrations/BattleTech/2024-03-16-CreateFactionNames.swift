//
//  CreateFactionNames.swift
//
// Creates the Faction Names model based upon the XML from MegaMek
//
// Author: Richard J Hancock
// Date: 2024/03/16
//

import Fluent
import FluentSQL

extension BattleTech {
    struct CreateFactionNames: AsyncMigration {
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

        func revert(on database: any Database) async throws {
            try await database.schema(for: BattleTech.FactionName.self).delete()
        }
    }
}

extension BattleTech.FactionName {
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
