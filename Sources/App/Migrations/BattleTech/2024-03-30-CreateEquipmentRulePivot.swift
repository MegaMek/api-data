/// CreateEquipmentRulePivot.swift
///
/// Fluent migration that creates the `equipment_rule_pivot` table, the join table between
/// equipment and the rules that govern it.
///
/// Author: Richard J Hancock
/// Date: 2024/03/16

import Fluent
import FluentSQL

extension BattleTech {
    /// Creates the `equipment_rule_pivot` table — the many-to-many join table between
    /// ``BattleTech/Rule`` and ``BattleTech/Equipment``.
    struct CreateEquipmentRulePivot: AsyncMigration {
        /// Creates the `equipment_rule_pivot` table.
        /// - Parameter database: The database connection to apply the schema change to.
        /// - Throws: An error if the schema change fails.
        func prepare(on database: any Database) async throws {
            try await database.schema(for: BattleTech.EquipmentRulePivot.self)
                .id()
                .field(
                    BattleTech.EquipmentRulePivot.V20240330.rule,
                    .uuid,
                    .references(BattleTech.Rule.self, BattleTech.Rule.V20240316.id, onDelete: .cascade)
                )
                .field(
                    BattleTech.EquipmentRulePivot.V20240330.equipment,
                    .uuid,
                    .references(BattleTech.Equipment.self, BattleTech.Equipment.V20240330.id, onDelete: .cascade)
                )
                .unique(
                    on:
                        BattleTech.EquipmentRulePivot.V20240330.rule,
                    BattleTech.EquipmentRulePivot.V20240330.equipment
                )
                .create()
        }

        /// Drops the `equipment_rule_pivot` table.
        /// - Parameter database: The database connection to apply the schema change to.
        /// - Throws: An error if the schema change fails.
        func revert(on database: any Database) async throws {
            try await database.schema(for: BattleTech.EquipmentRulePivot.self).delete()
        }
    }
}

extension BattleTech.EquipmentRulePivot {
    /// Column-name constants (``FieldKey``s) for the `equipment_rule_pivot` table, version
    /// 2024-03-30.
    enum V20240330 {
        static let schemaName = "equipment_rule_pivot"
        static let spaceName = "battletech"

        static let id = FieldKey(stringLiteral: "id")
        static let rule = FieldKey(stringLiteral: "rule_id")
        static let equipment = FieldKey(stringLiteral: "equipment_id")
    }
}
