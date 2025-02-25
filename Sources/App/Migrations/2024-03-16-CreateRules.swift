//
//  CreateRule.swift
//
// Creates the Rule model. Data Imported/Updated via data Import
//
// Author: Richard J Hancock
// Date: 2024/03/16
//

import Fluent
import FluentSQL

extension BattleTech {
    struct CreateRules: AsyncMigration {
        func prepare(on database: any Database) async throws {
            try await database.schema(for: BattleTech.Rule.self)
                .id()
                .field(BattleTech.Rule.V20240316.name, .string, .required)
                .unique(on: BattleTech.Rule.V20240316.name)
                .create()
        }

        func revert(on database: any Database) async throws {
            try await database.schema(for: BattleTech.Rule.self).delete()
        }
    }
}

extension BattleTech.Rule {
    enum V20240316 {
        static let schemaName = "rules"
        static let spaceName = "battletech"

        static let id = FieldKey(stringLiteral: "id")
        static let name = FieldKey(stringLiteral: "rule_name")
    }
}
