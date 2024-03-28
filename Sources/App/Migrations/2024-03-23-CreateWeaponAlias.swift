//
//  CreateWeaponAlias.swift
//
// Creates the Weapon Alias model. Data Imported/Updated via data Import
//
// Author: Richard J Hancock
// Date: 2024/03/23
//

import Fluent
import FluentSQL

extension BattleTech {
    struct CreateWeaponAlias: AsyncMigration {
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
                    BattleTech.Weapon.V20240316.id
                  )
                )
                .unique(
                    on:
                        BattleTech.WeaponAlias.V20240323.name,
                        BattleTech.WeaponAlias.V20240323.weapon
                )
                .create()
        }

        func revert(on database: any Database) async throws {
            try await database.schema(for: BattleTech.WeaponAlias.self).delete()
        }
    }
}

extension BattleTech.WeaponAlias {
    enum V20240323 {
        static let schemaName = "weapon_alias"
        static let spaceName = "battletech"

        static let id = FieldKey(stringLiteral: "id")
        static let name = FieldKey(stringLiteral: "name")
        static let weapon = FieldKey(stringLiteral: "weapon_id")
    }
}
