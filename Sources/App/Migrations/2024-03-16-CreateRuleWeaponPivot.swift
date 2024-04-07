//
//  CreateRuleWeaponPivot.swift
//
// Create the pivot for Rules with Weapons
//
// Author: Richard J Hancock
// Date: 2024/03/16
//

import Fluent
import FluentSQL

extension BattleTech {
  struct CreateRuleWeaponPivot: AsyncMigration {
    func prepare(on database: any Database) async throws {
      try await database.schema(for: BattleTech.RuleWeaponPivot.self)
        .id()
        .field(
          BattleTech.RuleWeaponPivot.V20240316.rule,
          .uuid,
          .references(BattleTech.Rule.self, BattleTech.Rule.V20240316.id, onDelete: .cascade)
        )
        .field(
          BattleTech.RuleWeaponPivot.V20240316.weapon,
          .uuid,
          .references(BattleTech.Weapon.self, BattleTech.Weapon.V20240316.id, onDelete: .cascade)
        )
        .unique(
          on:
            BattleTech.RuleWeaponPivot.V20240316.rule,
          BattleTech.RuleWeaponPivot.V20240316.weapon
        )
        .create()
    }

    func revert(on database: any Database) async throws {
      try await database.schema(for: BattleTech.RuleWeaponPivot.self).delete()
    }
  }
}

extension BattleTech.RuleWeaponPivot {
  enum V20240316 {
    static let schemaName = "rule_weapon_pivot"
    static let spaceName = "battletech"

    static let id = FieldKey(stringLiteral: "id")
    static let rule = FieldKey(stringLiteral: "rule_id")
    static let weapon = FieldKey(stringLiteral: "weapon_id")
  }
}
