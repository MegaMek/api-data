import Fluent
import Vapor

extension BattleTech.Weapon {
  static func findOrCreate(csvRow: Importers.WeaponCSVRow, on database: Database) async throws -> BattleTech.Weapon {
    var weapon: BattleTech.Weapon? = BattleTech.Weapon()

    if let foundWeapon = try await BattleTech.Weapon.findByNameOrAliases(
      name: csvRow.name(),
      aliases: csvRow.alias(),
      csvRow: csvRow,
      on: database
    ) {
      weapon = foundWeapon
    }

    try await weapon?.updateFromCSVRow(csvRow: csvRow, on: database)
    try await weapon?.save(on: database)
    return weapon!
  }

  static func findByNameOrAliases(
    name: String,
    aliases: [String],
    csvRow: Importers.WeaponCSVRow,
    on database: Database
  ) async throws -> BattleTech.Weapon? {

    let techLevel = try await BattleTech.TechLevel.findOrCreate(
        tentativeTechLevel: csvRow.staticTechLevel(),
        with: database
    )

    let techBase = try await BattleTech.TechBase.findOrCreate(
        tentativeTechBase: csvRow.techBase(),
        with: database
    )

    if let foundByName = try await BattleTech.Weapon.query(on: database)
      .filter(\.$name == csvRow.name())
      .filter(\.$techRating == csvRow.techRating())
      .filter(\.$tonnage == csvRow.tonnage())
      .filter(\.$techLevelStatic.$id == techLevel.id!)
      .filter(\.$techBase.$id == techBase.id!)
      .first() {
      return foundByName
    }

    if let foundByAliases = try await BattleTech.Weapon.query(on: database)
      .filter(\.$name ~~ aliases)
      .filter(\.$techRating == csvRow.techRating())
      .filter(\.$tonnage == csvRow.tonnage())
      .filter(\.$techLevelStatic.$id == techLevel.id!)
      .filter(\.$techBase.$id == techBase.id!)
      .first() {
      return foundByAliases
    }

    return nil
  }

  func updateFromCSVRow(csvRow: Importers.WeaponCSVRow, on database: Database) async throws {
    self.name = csvRow.name()
    self.techRating = csvRow.techRating()
    self.introductionDate = csvRow.introductionDate()
    self.prototypeDate = csvRow.prototypeDate()
    self.productionDate = csvRow.productionDate()
    self.commonDate = csvRow.commonDate()
    self.extinctionDate = csvRow.extinctionDate()
    self.reIntroductionDate = csvRow.reIntroductionDate()
    self.tonnage = csvRow.tonnage()
    self.criticalSlots = csvRow.criticalSlots()
    self.cost = csvRow.cost()
    self.battleValue = csvRow.battleValue()
    self.rulesReference = csvRow.rulesReference()
    self.minimalRange = csvRow.minimalRange()
    self.shortRange = csvRow.shortRange()
    self.mediumRange = csvRow.mediumRange()
    self.longRange = csvRow.longRange()
    self.extremeRange = csvRow.extremeRange()
    self.shortWaterRange = csvRow.shortWaterRange()
    self.mediumWaterRange = csvRow.mediumWaterRange()
    self.longWaterRange = csvRow.longWaterRange()
    self.extremeWaterRange = csvRow.extremeWaterRange()
    self.minimalRangeDamage = csvRow.minimalDamage()
    self.shortRangeDamage = csvRow.shortDamage()
    self.mediumRangeDamage = csvRow.mediumDamage()
    self.longRangeDamage = csvRow.longDamage()
    self.extremeRangeDamage = csvRow.extremeDamage()

    let techBase = try await BattleTech.TechBase.findOrCreate(
        tentativeTechBase: csvRow.techBase(),
        with: database
    )

    self.$techBase.id = techBase.id!

    let techLevel = try await BattleTech.TechLevel.findOrCreate(
        tentativeTechLevel: csvRow.staticTechLevel(),
        with: database
    )

    self.$techLevelStatic.id = techLevel.id!
    try await self.save(on: database)

    let rules = try await BattleTech.Rule.findOrCreate(
        tentativeRules: csvRow.rules(),
        with: database
    )

    for rule in rules {
        try await self.$rules.attach(rule, method: .ifNotExists, on: database)
    }

    let aliases = try await BattleTech.WeaponAlias.findOrCreate(
        tentativeAliases: csvRow.alias(),
        with: database
    )

    for alias in aliases {
      alias.$weapon.id = self.id!
      try await alias.save(on: database)
    }
  }
}
