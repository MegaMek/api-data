//
//  CreateAmmo.swift
//
// Creates the Ammo model for CSV Import
//
// Author: Richard J Hancock
// Date: 2024/03/27
//

import Fluent
import FluentSQL

extension BattleTech {
  struct CreateAmmo: AsyncMigration {
    func prepare(on database: any Database) async throws {
      try await database.schema(for: BattleTech.Ammo.self)
        .id()
        .field(BattleTech.Ammo.V20240327.name, .string, .required)
        .field(
          BattleTech.Ammo.V20240327.techBase, .uuid, .required,
          .references(BattleTech.TechBase.self, BattleTech.TechBase.V20240316.id)
        )
        .field(BattleTech.Ammo.V20240327.techRating, .string, .required)
        .field(
          BattleTech.Ammo.V20240327.techLevelStatic, .uuid, .required,
          .references(BattleTech.TechLevel.self, BattleTech.TechBase.V20240316.id)
        )
        .field(BattleTech.Ammo.V20240327.introductionDate, .string)
        .field(BattleTech.Ammo.V20240327.prototypeDate, .string)
        .field(BattleTech.Ammo.V20240327.productionDate, .string)
        .field(BattleTech.Ammo.V20240327.commonDate, .string)
        .field(BattleTech.Ammo.V20240327.extinctionDate, .string)
        .field(BattleTech.Ammo.V20240327.reIntroductionDate, .string)
        .field(BattleTech.Ammo.V20240327.tonnage, .double, .required)
        .field(BattleTech.Ammo.V20240327.criticalSlots, .int, .required)
        .field(BattleTech.Ammo.V20240327.cost, .double, .required)
        .field(BattleTech.Ammo.V20240327.battleValue, .double, .required)
        .field(BattleTech.Ammo.V20240327.rulesReference, .string)

        .field(BattleTech.Ammo.V20240327.countAsFlak, .bool, .required)
        .field(
          BattleTech.Ammo.V20240327.munitionType, .uuid, .required,
          .references(BattleTech.MunitionType.self, BattleTech.MunitionType.V20240327.id)
        )
        .field(BattleTech.Ammo.V20240327.damagePerShot, .int, .required)
        .field(BattleTech.Ammo.V20240327.rackSize, .int, .required)
        .field(BattleTech.Ammo.V20240327.shots, .int, .required)
        .field(BattleTech.Ammo.V20240327.ammoRatio, .double, .required)
        .field(BattleTech.Ammo.V20240327.isCapital, .bool, .required)
        .field(BattleTech.Ammo.V20240327.kilogramPerShot, .double, .required)
        .field(BattleTech.Ammo.V20240327.aeroUse, .bool, .required)

        .field(BattleTech.Ammo.V20240327.publishedAt, .datetime)
        .field(BattleTech.Ammo.V20240327.createdAt, .datetime)
        .field(BattleTech.Ammo.V20240327.updatedAt, .datetime)

        .unique(
          on:
            BattleTech.Ammo.V20240327.name,
          BattleTech.Ammo.V20240327.techBase,
          BattleTech.Ammo.V20240327.introductionDate,
          BattleTech.Ammo.V20240327.techLevelStatic,
          BattleTech.Ammo.V20240327.tonnage
        )
        .create()
    }

    func revert(on database: any Database) async throws {
      try await database.schema(for: BattleTech.Ammo.self).delete()
    }
  }
}

extension BattleTech.Ammo {
  enum V20240327 {
    static let schemaName = "ammo"
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

    static let countAsFlak = FieldKey(stringLiteral: "count_as_flak")
    static let munitionType = FieldKey(stringLiteral: "munition_type_id")
    static let damagePerShot = FieldKey(stringLiteral: "damage_per_shot")
    static let rackSize = FieldKey(stringLiteral: "rack_size")
    static let shots = FieldKey(stringLiteral: "shots")
    static let ammoRatio = FieldKey(stringLiteral: "ammo_ratio")
    static let isCapital = FieldKey(stringLiteral: "is_capital")
    static let kilogramPerShot = FieldKey(stringLiteral: "kilogram_per_shot")
    static let aeroUse = FieldKey(stringLiteral: "FieldKey")

    static let publishedAt = FieldKey(stringLiteral: "published_at")
    static let createdAt = FieldKey(stringLiteral: "created_at")
    static let updatedAt = FieldKey(stringLiteral: "updated_at")
  }
}
