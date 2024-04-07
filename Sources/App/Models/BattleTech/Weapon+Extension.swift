import Fluent
import Vapor

extension BattleTech.Weapon {
  static func findOrCreate(csvRow: Importers.WeaponCSVRow, on database: Database) async throws
    -> BattleTech.Weapon {
    var weapon: BattleTech.Weapon? = BattleTech.Weapon()

    if let foundWeapon = try await BattleTech.Weapon.findByNameOrAliases(
      name: csvRow.name(),
      aliases: csvRow.alias(),
      csvRow: csvRow,
      on: database
    ) {
      weapon = foundWeapon
    }

    do {
      try await weapon?.updateFromCSVRow(csvRow: csvRow, on: database)
      try await weapon?.save(on: database)
    } catch {
      print(String(reflecting: error))
    }

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

  func attachTechBase(techBase: String, on database: Database) async throws {
    let record = try await BattleTech.TechBase.findOrCreate(
      tentativeTechBase: techBase,
      with: database
    )

    self.$techBase.id = record.id!
  }

  func attachTechLevel(techLevel: String, on database: Database) async throws {
    let record = try await BattleTech.TechLevel.findOrCreate(
      tentativeTechLevel: techLevel,
      with: database
    )

    self.$techLevelStatic.id = record.id!
  }

  func attachRules(rules: [String], on database: Database) async throws {
    let records = try await BattleTech.Rule.findOrCreate(
      tentativeRules: rules,
      with: database
    )

    for rule in records {
      do {
        try await self.$rules.attach(rule, method: .ifNotExists, on: database)
      } catch {
        print(String(reflecting: error))
      }

    }
  }

  func attachAliases(aliases: [String], on database: Database) async throws {
    let records = try await BattleTech.WeaponAlias.findOrCreate(
      tentativeAliases: aliases,
      with: database
    )

    for alias in records {
      alias.$weapon.id = self.id!

      do {
        try await alias.save(on: database)
      } catch {
        print(String(reflecting: error))
      }

    }

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

    do {
      try await self.attachTechBase(techBase: csvRow.techBase(), on: database)
      try await self.attachTechLevel(techLevel: csvRow.staticTechLevel(), on: database)
      try await self.save(on: database)

      try await self.attachRules(rules: csvRow.rules(), on: database)
      try await self.attachAliases(aliases: csvRow.alias(), on: database)
    } catch {
      print(String(reflecting: error))
    }

  }
}
