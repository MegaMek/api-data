/// CreateRule.swift
///
/// Fluent migration that creates the `rules` table, storing named BattleTech rulebook
/// references. Row data itself is populated/updated via a separate data-import process.
///
/// Author: Richard J Hancock
/// Date: 2024/03/16

import Fluent
import FluentSQL

extension BattleTech {
    /// Creates the `rules` table.
    struct CreateRules: AsyncMigration {
        /// Creates the `rules` table.
        /// - Parameter database: The database connection to apply the schema change to.
        /// - Throws: An error if the schema change fails.
        func prepare(on database: any Database) async throws {
            try await database.schema(for: BattleTech.Rule.self)
                .id()
                .field(BattleTech.Rule.V20240316.name, .string, .required)
                .unique(on: BattleTech.Rule.V20240316.name)
                .create()
        }

        /// Drops the `rules` table.
        /// - Parameter database: The database connection to apply the schema change to.
        /// - Throws: An error if the schema change fails.
        func revert(on database: any Database) async throws {
            try await database.schema(for: BattleTech.Rule.self).delete()
        }
    }
}

extension BattleTech.Rule {
    /// Column-name constants (``FieldKey``s) for the `rules` table, version 2024-03-16.
    enum V20240316 {
        static let schemaName = "rules"
        static let spaceName = "battletech"

        static let id = FieldKey(stringLiteral: "id")
        static let name = FieldKey(stringLiteral: "rule_name")
    }
}
