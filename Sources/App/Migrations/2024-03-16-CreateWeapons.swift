//
//  CreateWeapons.swift
//
// Creates the Weapons model for CSV Import
//
// Author: Richard J Hancock
// Date: 2024/03/16
//

import Fluent
import FluentSQL

extension BattleTech {
  struct CreateWeapons: AsyncMigration {
    func prepare(on database: any Database) async throws {
      try await database.schema(for: BattleTech.Weapon.self)
        .id()
        .field(BattleTech.Weapon.V20240316.name, .string, .required)
        .field(
          BattleTech.Weapon.V20240316.techBase, .uuid, .required,
          .references(BattleTech.TechBase.self, BattleTech.TechBase.V20240316.id)
        )
        .field(BattleTech.Weapon.V20240316.techRating, .string, .required)
        .field(
          BattleTech.Weapon.V20240316.techLevelStatic, .uuid, .required,
          .references(BattleTech.TechLevel.self, BattleTech.TechBase.V20240316.id)
        )
        .field(BattleTech.Weapon.V20240316.introductionDate, .string)
        .field(BattleTech.Weapon.V20240316.prototypeDate, .string)
        .field(BattleTech.Weapon.V20240316.productionDate, .string)
        .field(BattleTech.Weapon.V20240316.commonDate, .string)
        .field(BattleTech.Weapon.V20240316.extinctionDate, .string)
        .field(BattleTech.Weapon.V20240316.reIntroductionDate, .string)
        .field(BattleTech.Weapon.V20240316.tonnage, .double, .required)
        .field(BattleTech.Weapon.V20240316.criticalSlots, .int, .required)
        .field(BattleTech.Weapon.V20240316.cost, .double, .required)
        .field(BattleTech.Weapon.V20240316.battleValue, .double, .required)
        .field(BattleTech.Weapon.V20240316.rulesReference, .string)
        .field(BattleTech.Weapon.V20240316.minimalRange, .int, .required)
        .field(BattleTech.Weapon.V20240316.shortRange, .int, .required)
        .field(BattleTech.Weapon.V20240316.mediumRange, .int, .required)
        .field(BattleTech.Weapon.V20240316.longRange, .int, .required)
        .field(BattleTech.Weapon.V20240316.extremeRange, .int, .required)
        .field(BattleTech.Weapon.V20240316.shortWaterRange, .int, .required)
        .field(BattleTech.Weapon.V20240316.mediumWaterRange, .int, .required)
        .field(BattleTech.Weapon.V20240316.longWaterRange, .int, .required)
        .field(BattleTech.Weapon.V20240316.extremeWaterRange, .int, .required)
        .field(BattleTech.Weapon.V20240316.minimalRangeDamage, .int, .required)
        .field(BattleTech.Weapon.V20240316.shortRangeDamage, .int, .required)
        .field(BattleTech.Weapon.V20240316.mediumRangeDamage, .int, .required)
        .field(BattleTech.Weapon.V20240316.longRangeDamage, .int, .required)
        .field(BattleTech.Weapon.V20240316.extremeRangeDamage, .int, .required)

        .field(BattleTech.Weapon.V20240316.publishedAt, .datetime)
        .field(BattleTech.Weapon.V20240316.createdAt, .datetime)
        .field(BattleTech.Weapon.V20240316.updatedAt, .datetime)

        .unique(
          on:
            BattleTech.Weapon.V20240316.name,
          BattleTech.Weapon.V20240316.techBase,
          BattleTech.Weapon.V20240316.introductionDate,
          BattleTech.Weapon.V20240316.techLevelStatic,
          BattleTech.Weapon.V20240316.tonnage
        )
        .create()
    }

    func revert(on database: any Database) async throws {
      try await database.schema(for: BattleTech.Weapon.self).delete()
    }
  }
}

extension BattleTech.Weapon {
  enum V20240316 {
    static let schemaName = "weapons"
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
    static let minimalRange = FieldKey(stringLiteral: "minimal_range")
    static let shortRange = FieldKey(stringLiteral: "short_range")
    static let mediumRange = FieldKey(stringLiteral: "medium_range")
    static let longRange = FieldKey(stringLiteral: "long_range")
    static let extremeRange = FieldKey(stringLiteral: "extreme_range")
    static let shortWaterRange = FieldKey(stringLiteral: "short_water_range")
    static let mediumWaterRange = FieldKey(stringLiteral: "medium_water_range")
    static let longWaterRange = FieldKey(stringLiteral: "long_water_range")
    static let extremeWaterRange = FieldKey(stringLiteral: "extreme_water_range")
    static let minimalRangeDamage = FieldKey(stringLiteral: "minimal_range_damage")
    static let shortRangeDamage = FieldKey(stringLiteral: "short_range_damage")
    static let mediumRangeDamage = FieldKey(stringLiteral: "medium_range_damage")
    static let longRangeDamage = FieldKey(stringLiteral: "long_range_damage")
    static let extremeRangeDamage = FieldKey(stringLiteral: "extreme_range_damage")

    static let publishedAt = FieldKey(stringLiteral: "published_at")
    static let createdAt = FieldKey(stringLiteral: "created_at")
    static let updatedAt = FieldKey(stringLiteral: "updated_at")
  }
}
