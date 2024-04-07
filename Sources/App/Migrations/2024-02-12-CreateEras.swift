//
//  CreateEras.swift
//
// Creates the Eras model based upon the XML from MegaMek
//
// Author: Richard J Hancock
// Date: 2024/02/12
//

import Fluent
import FluentSQL

extension BattleTech {
  struct CreateEras: AsyncMigration {
    func prepare(on database: any Database) async throws {
      try await database.schema(for: BattleTech.Era.self)
        .id()
        .field(BattleTech.Era.V20240212.code, .string, .required)
        .field(BattleTech.Era.V20240212.name, .string, .required)
        .field(BattleTech.Era.V20240212.endYear, .int)
        .field(BattleTech.Era.V20240212.flag, .string, .required)
        .field(BattleTech.Era.V20240212.icon, .string)
        .field(BattleTech.Era.V20240212.mulId, .int)

        .field(BattleTech.Era.V20240212.publishedAt, .datetime)
        .field(BattleTech.Era.V20240212.createdAt, .datetime)
        .field(BattleTech.Era.V20240212.updatedAt, .datetime)

        .unique(on: BattleTech.Era.V20240212.name)
        .unique(on: BattleTech.Era.V20240212.endYear)
        .unique(on: BattleTech.Era.V20240212.flag)
        .create()
    }

    func revert(on database: any Database) async throws {
      try await database.schema(for: BattleTech.Era.self).delete()
    }
  }
}

extension BattleTech.Era {
  enum V20240212 {
    static let schemaName = "eras"
    static let spaceName = "battletech"

    static let id = FieldKey(stringLiteral: "id")
    static let name = FieldKey(stringLiteral: "name")
    static let code = FieldKey(stringLiteral: "code")
    static let endYear = FieldKey(stringLiteral: "end_year")
    static let flag = FieldKey(stringLiteral: "flag")
    static let icon = FieldKey(stringLiteral: "icon")
    static let mulId = FieldKey(stringLiteral: "mul_id")

    static let publishedAt = FieldKey(stringLiteral: "published_at")
    static let createdAt = FieldKey(stringLiteral: "created_at")
    static let updatedAt = FieldKey(stringLiteral: "updated_at")
  }
}
