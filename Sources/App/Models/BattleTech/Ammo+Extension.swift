import Fluent
import Vapor

extension BattleTech.Ammo {
  static func findOrCreate(csvRow: Importers.AmmoCSVRow, on database: Database) async throws
    -> BattleTech.Ammo {
    var ammo: BattleTech.Ammo? = BattleTech.Ammo()

    if let foundAmmo = try await BattleTech.Ammo.findByNameOrAliases(
      name: csvRow.name(),
      aliases: csvRow.alias(),
      csvRow: csvRow,
      on: database
    ) {
      ammo = foundAmmo
    }

    try await ammo?.updateFromCSVRow(csvRow: csvRow, on: database)
    try await ammo?.save(on: database)
    return ammo!
  }

  static func findByNameOrAliases(
    name: String,
    aliases: [String],
    csvRow: Importers.AmmoCSVRow,
    on database: Database
  ) async throws -> BattleTech.Ammo? {

    let techLevel = try await BattleTech.TechLevel.findOrCreate(
      tentativeTechLevel: csvRow.staticTechLevel(),
      with: database
    )

    let techBase = try await BattleTech.TechBase.findOrCreate(
      tentativeTechBase: csvRow.techBase(),
      with: database
    )

    if let foundByName = try await BattleTech.Ammo.query(on: database)
      .filter(\.$name == csvRow.name())
      .filter(\.$techRating == csvRow.techRating())
      .filter(\.$tonnage == csvRow.tonnage())
      .filter(\.$techLevelStatic.$id == techLevel.id!)
      .filter(\.$techBase.$id == techBase.id!)
      .first() {
      return foundByName
    }

    if let foundByAliases = try await BattleTech.Ammo.query(on: database)
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

  func attachMunitionType(munitionType: String, on database: Database) async throws {
    let record = try await BattleTech.MunitionType.findOrCreate(
      tentativeMunitionType: munitionType,
      with: database
    )

    self.$munitionType.id = record.id!
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
    let records = try await BattleTech.AmmoAlias.findOrCreate(
      tentativeAliases: aliases,
      with: database
    )

    for alias in records {
      alias.$ammo.id = self.id!
      do {
        try await alias.save(on: database)
      } catch {
        print(String(reflecting: error))
      }

    }

  }

  func updateFromCSVRow(csvRow: Importers.AmmoCSVRow, on database: Database) async throws {
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
    self.countAsFlak = csvRow.countAsFlak()
    self.damagePerShot = csvRow.damagePerShot()
    self.rackSize = csvRow.rackSize()
    self.shots = csvRow.shots()
    self.ammoRatio = csvRow.ammoRatio()
    self.isCapital = csvRow.isCapital()
    self.kilogramPerShot = csvRow.kilogramPerShot()
    self.aeroUse = csvRow.aeroUse()

    do {
      try await self.attachTechBase(techBase: csvRow.techBase(), on: database)
      try await self.attachTechLevel(techLevel: csvRow.staticTechLevel(), on: database)
      try await self.attachMunitionType(munitionType: csvRow.munitionType(), on: database)
      try await self.save(on: database)

      try await self.attachRules(rules: csvRow.rules(), on: database)
      try await self.attachAliases(aliases: csvRow.alias(), on: database)
    } catch {
      print(String(reflecting: error))
    }
  }
}
