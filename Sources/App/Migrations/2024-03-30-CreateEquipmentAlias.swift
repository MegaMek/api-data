//
//  CreateEquipmentAlias.swift
//
// Creates the Equipment Alias model. Data Imported/Updated via data Import
//
// Author: Richard J Hancock
// Date: 2024/03/30
//

import Fluent
import FluentSQL

extension BattleTech {
    struct CreateEquipmentAlias: AsyncMigration {
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
                    BattleTech.Equipment.V20240330.id
                  )
                )
                .unique(
                    on:
                        BattleTech.EquipmentAlias.V20240330.name,
                        BattleTech.EquipmentAlias.V20240330.equipment
                )
                .create()
        }

        func revert(on database: any Database) async throws {
            try await database.schema(for: BattleTech.EquipmentAlias.self).delete()
        }
    }
}

extension BattleTech.EquipmentAlias {
    enum V20240330 {
        static let schemaName = "equipment_alias"
        static let spaceName = "battletech"

        static let id = FieldKey(stringLiteral: "id")
        static let name = FieldKey(stringLiteral: "name")
        static let equipment = FieldKey(stringLiteral: "equipment_id")
    }
}
