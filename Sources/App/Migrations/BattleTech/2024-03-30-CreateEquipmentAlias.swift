/// CreateEquipmentAlias.swift
///
/// Fluent migration that creates the `equipment_alias` table, storing alternate/historical
/// names for an equipment record. Row data itself is populated/updated via a separate
/// data-import process.
///
/// Author: Richard J Hancock
/// Date: 2024/03/30

import Fluent
import FluentSQL

extension BattleTech {
    /// Creates the `equipment_alias` table, which references `equipment` via a required
    /// `equipment_id` foreign key.
    struct CreateEquipmentAlias: AsyncMigration {
        /// Creates the `equipment_alias` table.
        /// - Parameter database: The database connection to apply the schema change to.
        /// - Throws: An error if the schema change fails.
        func prepare(on database: any Database) async throws {
            try await database.schema(for: BattleTech.EquipmentAlias.self)
                .id()
                .field(BattleTech.EquipmentAlias.V20240330.name, .string, .required)
                .field(
                    BattleTech.EquipmentAlias.V20240330.equipment,
                    .uuid,
                    .required,
                    .references(
                        BattleTech.Equipment.self,
                        BattleTech.Equipment.V20240330.id,
                        onDelete: .cascade
                    )
                )
                .unique(
                    on:
                        BattleTech.EquipmentAlias.V20240330.name,
                    BattleTech.EquipmentAlias.V20240330.equipment
                )
                .create()
        }

        /// Drops the `equipment_alias` table.
        /// - Parameter database: The database connection to apply the schema change to.
        /// - Throws: An error if the schema change fails.
        func revert(on database: any Database) async throws {
            try await database.schema(for: BattleTech.EquipmentAlias.self).delete()
        }
    }
}

extension BattleTech.EquipmentAlias {
    /// Column-name constants (``FieldKey``s) for the `equipment_alias` table, version
    /// 2024-03-30.
    enum V20240330 {
        static let schemaName = "equipment_alias"
        static let spaceName = "battletech"

        static let id = FieldKey(stringLiteral: "id")
        static let name = FieldKey(stringLiteral: "name")
        static let equipment = FieldKey(stringLiteral: "equipment_id")
    }
}
