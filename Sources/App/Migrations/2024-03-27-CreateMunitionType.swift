//
//  CreateTechBase.swift
//
// Creates the Tech Base model. Data Imported/Updated via data Import
//
// Author: Richard J Hancock
// Date: 2024/03/16
//

import Fluent
import FluentSQL

extension BattleTech {
  struct CreateMunitionType: AsyncMigration {
    func prepare(on database: any Database) async throws {
      try await database.schema(for: BattleTech.MunitionType.self)
        .id()
        .field(BattleTech.MunitionType.V20240327.name, .string, .required)
        .unique(on: BattleTech.MunitionType.V20240327.name)
        .create()
    }

    func revert(on database: any Database) async throws {
      try await database.schema(for: BattleTech.MunitionType.self).delete()
    }
  }
}

extension BattleTech.MunitionType {
  enum V20240327 {
    static let schemaName = "munition_type"
    static let spaceName = "battletech"

    static let id = FieldKey(stringLiteral: "id")
    static let name = FieldKey(stringLiteral: "munition_type_name")
  }
}
