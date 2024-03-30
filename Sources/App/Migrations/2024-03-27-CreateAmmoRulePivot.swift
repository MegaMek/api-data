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
    struct CreateAmmoRulePivot: AsyncMigration {
        func prepare(on database: any Database) async throws {
            try await database.schema(for: BattleTech.AmmoRulePivot.self)
                .id()
                .field(
                  BattleTech.AmmoRulePivot.V20240327.rule,
                  .uuid,
                  .references(BattleTech.Rule.self, BattleTech.Rule.V20240316.id))
                .field(
                  BattleTech.AmmoRulePivot.V20240327.ammo,
                  .uuid,
                  .references(BattleTech.Ammo.self, BattleTech.Ammo.V20240327.id))
                .unique(on:
                  BattleTech.AmmoRulePivot.V20240327.rule,
                  BattleTech.AmmoRulePivot.V20240327.ammo
                )
                .create()
        }

        func revert(on database: any Database) async throws {
            try await database.schema(for: BattleTech.AmmoRulePivot.self).delete()
        }
    }
}

extension BattleTech.AmmoRulePivot {
    enum V20240327 {
        static let schemaName = "ammo_rule_pivot"
        static let spaceName = "battletech"

        static let id = FieldKey(stringLiteral: "id")
        static let rule = FieldKey(stringLiteral: "rule_id")
        static let ammo = FieldKey(stringLiteral: "ammo_id")
    }
}
