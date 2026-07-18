/// CreateMunitionType.swift
///
/// Fluent migration that creates the `munition_type` table, storing munition-type lookup
/// values referenced by ammo. Row data itself is populated/updated via a separate data-import
/// process.
///
/// Author: Richard J Hancock
/// Date: 2024/03/16

import Fluent
import FluentSQL

extension BattleTech {
    /// Creates the `munition_type` table.
    struct CreateMunitionType: AsyncMigration {
        /// Creates the `munition_type` table.
        /// - Parameter database: The database connection to apply the schema change to.
        /// - Throws: An error if the schema change fails.
        func prepare(on database: any Database) async throws {
            try await database.schema(for: BattleTech.MunitionType.self)
                .id()
                .field(BattleTech.MunitionType.V20240327.name, .string, .required)
                .unique(on: BattleTech.MunitionType.V20240327.name)
                .create()
        }

        /// Drops the `munition_type` table.
        /// - Parameter database: The database connection to apply the schema change to.
        /// - Throws: An error if the schema change fails.
        func revert(on database: any Database) async throws {
            try await database.schema(for: BattleTech.MunitionType.self).delete()
        }
    }
}

extension BattleTech.MunitionType {
    /// Column-name constants (``FieldKey``s) for the `munition_type` table, version 2024-03-27.
    enum V20240327 {
        static let schemaName = "munition_type"
        static let spaceName = "battletech"

        static let id = FieldKey(stringLiteral: "id")
        static let name = FieldKey(stringLiteral: "munition_type_name")
    }
}
