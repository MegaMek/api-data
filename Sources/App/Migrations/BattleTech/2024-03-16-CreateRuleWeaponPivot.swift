/// CreateRuleWeaponPivot.swift
///
/// Fluent migration that creates the `rule_weapon_pivot` table, the join table between weapons
/// and the rules that govern them.
///
/// Author: Richard J Hancock
/// Date: 2024/03/16

import Fluent
import FluentSQL

extension BattleTech {
    /// Creates the `rule_weapon_pivot` table — the many-to-many join table between
    /// ``BattleTech/Rule`` and ``BattleTech/Weapon``.
    struct CreateRuleWeaponPivot: AsyncMigration {
        /// Creates the `rule_weapon_pivot` table.
        /// - Parameter database: The database connection to apply the schema change to.
        /// - Throws: An error if the schema change fails.
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

        /// Drops the `rule_weapon_pivot` table.
        /// - Parameter database: The database connection to apply the schema change to.
        /// - Throws: An error if the schema change fails.
        func revert(on database: any Database) async throws {
            try await database.schema(for: BattleTech.RuleWeaponPivot.self).delete()
        }
    }
}

extension BattleTech.RuleWeaponPivot {
    /// Column-name constants (``FieldKey``s) for the `rule_weapon_pivot` table, version
    /// 2024-03-16.
    enum V20240316 {
        static let schemaName = "rule_weapon_pivot"
        static let spaceName = "battletech"

        static let id = FieldKey(stringLiteral: "id")
        static let rule = FieldKey(stringLiteral: "rule_id")
        static let weapon = FieldKey(stringLiteral: "weapon_id")
    }
}
