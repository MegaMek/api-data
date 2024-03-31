//
//  CreateEquipmentRulePivot.swift
//
// Create the pivot for Rules with Weapons
//
// Author: Richard J Hancock
// Date: 2024/03/16
//

import Fluent
import FluentSQL

extension BattleTech {
    struct CreateEquipmentRulePivot: AsyncMigration {
        func prepare(on database: any Database) async throws {
            try await database.schema(for: BattleTech.EquipmentRulePivot.self)
                .id()
                .field(
                  BattleTech.EquipmentRulePivot.V20240330.rule,
                  .uuid,
                  .references(BattleTech.Rule.self, BattleTech.Rule.V20240316.id))
                .field(
                  BattleTech.EquipmentRulePivot.V20240330.equipment,
                  .uuid,
                  .references(BattleTech.Equipment.self, BattleTech.Equipment.V20240330.id))
                .unique(on:
                  BattleTech.EquipmentRulePivot.V20240330.rule,
                  BattleTech.EquipmentRulePivot.V20240330.equipment
                )
                .create()
        }

        func revert(on database: any Database) async throws {
            try await database.schema(for: BattleTech.EquipmentRulePivot.self).delete()
        }
    }
}

extension BattleTech.EquipmentRulePivot {
    enum V20240330 {
        static let schemaName = "equipment_rule_pivot"
        static let spaceName = "battletech"

        static let id = FieldKey(stringLiteral: "id")
        static let rule = FieldKey(stringLiteral: "rule_id")
        static let equipment = FieldKey(stringLiteral: "equipment_id")
    }
}
