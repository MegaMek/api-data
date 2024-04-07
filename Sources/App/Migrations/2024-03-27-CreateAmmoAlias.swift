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
  struct CreateAmmoAlias: AsyncMigration {
    func prepare(on database: any Database) async throws {
      try await database.schema(for: BattleTech.AmmoAlias.self)
        .id()
        .field(BattleTech.AmmoAlias.V20240327.name, .string, .required)
        .field(
          BattleTech.AmmoAlias.V20240327.ammo,
          .uuid,
          .required,
          .references(
            BattleTech.Ammo.self,
            BattleTech.Ammo.V20240327.id,
            onDelete: .cascade
          )
        )
        .unique(
          on:
            BattleTech.AmmoAlias.V20240327.name,
          BattleTech.AmmoAlias.V20240327.ammo
        )
        .create()
    }

    func revert(on database: any Database) async throws {
      try await database.schema(for: BattleTech.AmmoAlias.self).delete()
    }
  }
}

extension BattleTech.AmmoAlias {
  enum V20240327 {
    static let schemaName = "ammo_alias"
    static let spaceName = "battletech"

    static let id = FieldKey(stringLiteral: "id")
    static let name = FieldKey(stringLiteral: "name")
    static let ammo = FieldKey(stringLiteral: "ammo_id")
  }
}
