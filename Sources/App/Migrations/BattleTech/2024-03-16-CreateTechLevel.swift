/// CreateTechLevel.swift
///
/// Fluent migration that creates the `tech_level` table, storing tech-level lookup values (e.g.
/// Introductory, Standard, Advanced) referenced by weapons, ammo, and equipment. Row data itself
/// is populated/updated via a separate data-import process.
///
/// Author: Richard J Hancock
/// Date: 2024/03/16

import Fluent
import FluentSQL

extension BattleTech {
    /// Creates the `tech_level` table.
    struct CreateTechLevel: AsyncMigration {
        /// Creates the `tech_level` table.
        /// - Parameter database: The database connection to apply the schema change to.
        /// - Throws: An error if the schema change fails.
        func prepare(on database: any Database) async throws {
            try await database.schema(for: BattleTech.TechLevel.self)
                .id()
                .field(BattleTech.TechLevel.V20240316.name, .string, .required)
                .unique(on: BattleTech.TechLevel.V20240316.name)
                .create()
        }

        /// Drops the `tech_level` table.
        /// - Parameter database: The database connection to apply the schema change to.
        /// - Throws: An error if the schema change fails.
        func revert(on database: any Database) async throws {
            try await database.schema(for: BattleTech.TechLevel.self).delete()
        }
    }
}

extension BattleTech.TechLevel {
    /// Column-name constants (``FieldKey``s) for the `tech_level` table, version 2024-03-16.
    enum V20240316 {
        static let schemaName = "tech_level"
        static let spaceName = "battletech"

        static let id = FieldKey(stringLiteral: "id")
        static let name = FieldKey(stringLiteral: "tech_level_name")
    }
}
