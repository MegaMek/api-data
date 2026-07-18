/// CreateWeaponAlias.swift
///
/// Fluent migration that creates the `weapon_alias` table, storing alternate/historical names
/// for a weapon. Row data itself is populated/updated via a separate data-import process.
///
/// Author: Richard J Hancock
/// Date: 2024/03/23

import Fluent
import FluentSQL

extension BattleTech {
    /// Creates the `weapon_alias` table, which references `weapons` via a required
    /// `weapon_id` foreign key.
    struct CreateWeaponAlias: AsyncMigration {
        /// Creates the `weapon_alias` table.
        /// - Parameter database: The database connection to apply the schema change to.
        /// - Throws: An error if the schema change fails.
        func prepare(on database: any Database) async throws {
            try await database.schema(for: BattleTech.WeaponAlias.self)
                .id()
                .field(BattleTech.WeaponAlias.V20240323.name, .string, .required)
                .field(
                    BattleTech.WeaponAlias.V20240323.weapon,
                    .uuid,
                    .required,
                    .references(
                        BattleTech.Weapon.self,
                        BattleTech.Weapon.V20240316.id,
                        onDelete: .cascade
                    )
                )
                .unique(
                    on:
                        BattleTech.WeaponAlias.V20240323.name,
                    BattleTech.WeaponAlias.V20240323.weapon
                )
                .create()
        }

        /// Drops the `weapon_alias` table.
        /// - Parameter database: The database connection to apply the schema change to.
        /// - Throws: An error if the schema change fails.
        func revert(on database: any Database) async throws {
            try await database.schema(for: BattleTech.WeaponAlias.self).delete()
        }
    }
}

extension BattleTech.WeaponAlias {
    /// Column-name constants (``FieldKey``s) for the `weapon_alias` table, version 2024-03-23.
    enum V20240323 {
        static let schemaName = "weapon_alias"
        static let spaceName = "battletech"

        static let id = FieldKey(stringLiteral: "id")
        static let name = FieldKey(stringLiteral: "name")
        static let weapon = FieldKey(stringLiteral: "weapon_id")
    }
}
