/// CreateTechBase.swift
///
/// Fluent migration that creates the `tech_base` table, storing tech-base lookup values (e.g.
/// Inner Sphere, Clan) referenced by weapons, ammo, and equipment. Row data itself is
/// populated/updated via a separate data-import process.
///
/// Author: Richard J Hancock
/// Date: 2024/03/16

import Fluent
import FluentSQL

extension BattleTech {
    /// Creates the `tech_base` table.
    struct CreateTechBase: AsyncMigration {
        /// Creates the `tech_base` table.
        /// - Parameter database: The database connection to apply the schema change to.
        /// - Throws: An error if the schema change fails.
        func prepare(on database: any Database) async throws {
            try await database.schema(for: BattleTech.TechBase.self)
                .id()
                .field(BattleTech.TechBase.V20240316.name, .string, .required)
                .unique(on: BattleTech.TechBase.V20240316.name)
                .create()
        }

        /// Drops the `tech_base` table.
        /// - Parameter database: The database connection to apply the schema change to.
        /// - Throws: An error if the schema change fails.
        func revert(on database: any Database) async throws {
            try await database.schema(for: BattleTech.TechBase.self).delete()
        }
    }
}

extension BattleTech.TechBase {
    /// Column-name constants (``FieldKey``s) for the `tech_base` table, version 2024-03-16.
    enum V20240316 {
        static let schemaName = "tech_base"
        static let spaceName = "battletech"

        static let id = FieldKey(stringLiteral: "id")
        static let name = FieldKey(stringLiteral: "tech_base_name")
    }
}
