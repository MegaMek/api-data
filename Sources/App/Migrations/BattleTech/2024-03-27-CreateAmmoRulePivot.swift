/// CreateAmmoRulePivot.swift
///
/// Fluent migration that creates the `ammo_rule_pivot` table, the join table between ammo and
/// the rules that govern it.
///
/// Author: Richard J Hancock
/// Date: 2024/03/16

import Fluent
import FluentSQL

extension BattleTech {
    /// Creates the `ammo_rule_pivot` table — the many-to-many join table between
    /// ``BattleTech/Rule`` and ``BattleTech/Ammo``.
    struct CreateAmmoRulePivot: AsyncMigration {
        /// Creates the `ammo_rule_pivot` table.
        /// - Parameter database: The database connection to apply the schema change to.
        /// - Throws: An error if the schema change fails.
        func prepare(on database: any Database) async throws {
            try await database.schema(for: BattleTech.AmmoRulePivot.self)
                .id()
                .field(
                    BattleTech.AmmoRulePivot.V20240327.rule,
                    .uuid,
                    .references(BattleTech.Rule.self, BattleTech.Rule.V20240316.id, onDelete: .cascade)
                )
                .field(
                    BattleTech.AmmoRulePivot.V20240327.ammo,
                    .uuid,
                    .references(BattleTech.Ammo.self, BattleTech.Ammo.V20240327.id, onDelete: .cascade)
                )
                .unique(
                    on:
                        BattleTech.AmmoRulePivot.V20240327.rule,
                    BattleTech.AmmoRulePivot.V20240327.ammo
                )
                .create()
        }

        /// Drops the `ammo_rule_pivot` table.
        /// - Parameter database: The database connection to apply the schema change to.
        /// - Throws: An error if the schema change fails.
        func revert(on database: any Database) async throws {
            try await database.schema(for: BattleTech.AmmoRulePivot.self).delete()
        }
    }
}

extension BattleTech.AmmoRulePivot {
    /// Column-name constants (``FieldKey``s) for the `ammo_rule_pivot` table, version
    /// 2024-03-27.
    enum V20240327 {
        static let schemaName = "ammo_rule_pivot"
        static let spaceName = "battletech"

        static let id = FieldKey(stringLiteral: "id")
        static let rule = FieldKey(stringLiteral: "rule_id")
        static let ammo = FieldKey(stringLiteral: "ammo_id")
    }
}
