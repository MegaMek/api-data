//
//  CreateTechBase.swift
//
// Creates the Tech Base model. Data Imported/Updated via data Import
//
// Author: Richard J Hancock
// Date: 2024/03/16
//

import Fluent
import FluentSQL

extension BattleTech {
    struct CreateTechBase: AsyncMigration {
        func prepare(on database: any Database) async throws {
            try await database.schema(for: BattleTech.TechBase.self)
                .id()
                .field(BattleTech.TechBase.V20240316.name, .string, .required)
                .unique(on: BattleTech.TechBase.V20240316.name)
                .create()
        }

        func revert(on database: any Database) async throws {
            try await database.schema(for: BattleTech.TechBase.self).delete()
        }
    }
}

extension BattleTech.TechBase {
    enum V20240316 {
        static let schemaName = "tech_base"
        static let spaceName = "battletech"

        static let id = FieldKey(stringLiteral: "id")
        static let name = FieldKey(stringLiteral: "tech_base_name")
    }
}
