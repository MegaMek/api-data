//
//  AddImageToFactionName.swift
//
// Adds the Image to Faction Name
//
// Author: Richard J Hancock
// Date: 2024/04/15
//

import Fluent
import FluentSQL

extension BattleTech {
    struct AddImageToFactionName: AsyncMigration {
        func prepare(on database: any Database) async throws {
            try await database.schema(for: BattleTech.FactionName.self)
                .field(BattleTech.FactionName.V20240415.image, .string)
                .update()
        }

        func revert(on database: any Database) async throws {
            try await database.schema(for: BattleTech.FactionName.self)
                .deleteField(BattleTech.FactionName.V20240415.image)
                .update()
        }
    }
}

extension BattleTech.FactionName {
    enum V20240415 {
        static let image = FieldKey(stringLiteral: "image_name")
    }
}
