//
//  CreateEquipment.swift
//
// Creates the Equipment model for CSV Import
//
// Author: Richard J Hancock
// Date: 2024/03/30
//

import Fluent
import FluentSQL

extension BattleTech {
  struct CreateEquipment: AsyncMigration {
    func prepare(on database: any Database) async throws {
      try await database.schema(for: BattleTech.Equipment.self)
        .id()
        .field(BattleTech.Equipment.V20240330.name, .string, .required)
        .field(
          BattleTech.Equipment.V20240330.techBase, .uuid, .required,
          .references(BattleTech.TechBase.self, BattleTech.TechBase.V20240316.id)
        )
        .field(BattleTech.Equipment.V20240330.techRating, .string, .required)
        .field(
          BattleTech.Equipment.V20240330.techLevelStatic, .uuid, .required,
          .references(BattleTech.TechLevel.self, BattleTech.TechBase.V20240316.id)
        )
        .field(BattleTech.Equipment.V20240330.introductionDate, .string)
        .field(BattleTech.Equipment.V20240330.prototypeDate, .string)
        .field(BattleTech.Equipment.V20240330.productionDate, .string)
        .field(BattleTech.Equipment.V20240330.commonDate, .string)
        .field(BattleTech.Equipment.V20240330.extinctionDate, .string)
        .field(BattleTech.Equipment.V20240330.reIntroductionDate, .string)
        .field(BattleTech.Equipment.V20240330.tonnage, .double, .required)
        .field(BattleTech.Equipment.V20240330.criticalSlots, .int, .required)
        .field(BattleTech.Equipment.V20240330.cost, .double, .required)
        .field(BattleTech.Equipment.V20240330.battleValue, .double, .required)
        .field(BattleTech.Equipment.V20240330.rulesReference, .string)

        .field(BattleTech.Equipment.V20240330.publishedAt, .datetime)
        .field(BattleTech.Equipment.V20240330.createdAt, .datetime)
        .field(BattleTech.Equipment.V20240330.updatedAt, .datetime)

        .unique(
          on:
            BattleTech.Equipment.V20240330.name,
          BattleTech.Equipment.V20240330.techBase,
          BattleTech.Equipment.V20240330.introductionDate,
          BattleTech.Equipment.V20240330.techLevelStatic,
          BattleTech.Equipment.V20240330.tonnage
        )
        .create()
    }

    func revert(on database: any Database) async throws {
      try await database.schema(for: BattleTech.Equipment.self).delete()
    }
  }
}

extension BattleTech.Equipment {
  enum V20240330 {
    static let schemaName = "equipment"
    static let spaceName = "battletech"

    static let id = FieldKey(stringLiteral: "id")
    static let name = FieldKey(stringLiteral: "name")
    static let techBase = FieldKey(stringLiteral: "tech_base_id")
    static let techRating = FieldKey(stringLiteral: "tech_rating")
    static let techLevelStatic = FieldKey(stringLiteral: "tech_level_id")
    static let introductionDate = FieldKey(stringLiteral: "introduction_date")
    static let prototypeDate = FieldKey(stringLiteral: "prototype_date")
    static let productionDate = FieldKey(stringLiteral: "production_date")
    static let commonDate = FieldKey(stringLiteral: "common_date")
    static let extinctionDate = FieldKey(stringLiteral: "extinction_date")
    static let reIntroductionDate = FieldKey(stringLiteral: "re_introduction_date")
    static let tonnage = FieldKey(stringLiteral: "tonnage")
    static let criticalSlots = FieldKey(stringLiteral: "critical_slots")
    static let cost = FieldKey(stringLiteral: "cost")
    static let battleValue = FieldKey(stringLiteral: "battle_value")
    static let rulesReference = FieldKey(stringLiteral: "rules_reference")

    static let publishedAt = FieldKey(stringLiteral: "published_at")
    static let createdAt = FieldKey(stringLiteral: "created_at")
    static let updatedAt = FieldKey(stringLiteral: "updated_at")
  }
}
