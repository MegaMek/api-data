extension Importers {
  enum WeaponHeaders: Int {
    case name
    case techBase
    case rules
    case techRating
    case staticTechLevel
    case introductionDate
    case prototypeDate
    case productionDate
    case commonDate
    case extinctionDate
    case reIntroductionDate
    case tonnage
    case criticalSlots
    case cost
    case battleValue
    case rulesReference
    case minimalRange
    case shortRange
    case mediumRange
    case longRange
    case extremeRange
    case shortWaterRange
    case mediumWaterRange
    case longWaterRange
    case extremeWaterRange
    case minimalDamage
    case shortDamage
    case mediumDamage
    case longDamage
    case extremeDamage
    case alias
  }
}

extension Importers {
  struct WeaponCSVRow {
    init(row: [String]) { self.row = row }

    private let row: [String]

    func name() -> String { row[Importers.WeaponHeaders.name.rawValue] }

    func techBase() -> String { row[Importers.WeaponHeaders.techBase.rawValue] }

    func rulesRaw() -> String { row[Importers.WeaponHeaders.rules.rawValue] }

    func rules() -> [String] {
      row[Importers.WeaponHeaders.rules.rawValue].split(
        separator: "/",
        omittingEmptySubsequences: true
      ).map(String.init)
    }

    func techRating() -> String { row[Importers.WeaponHeaders.techRating.rawValue] }

    func staticTechLevel() -> String { row[Importers.WeaponHeaders.staticTechLevel.rawValue] }

    func introductionDate() -> String? {
      let value = row[Importers.WeaponHeaders.introductionDate.rawValue]

      return value.count > 0 ? value : nil
    }

    func prototypeDate() -> String? {
      let value = row[Importers.WeaponHeaders.prototypeDate.rawValue]

      return value.count > 0 ? value : nil
    }

    func productionDate() -> String? {
      let value = row[Importers.WeaponHeaders.productionDate.rawValue]

      return value.count > 0 ? value : nil
    }

    func commonDate() -> String? {
      let value = row[Importers.WeaponHeaders.commonDate.rawValue]

      return value.count > 0 ? value : nil
    }

    func extinctionDate() -> String? {
      let value = row[Importers.WeaponHeaders.extinctionDate.rawValue]

      return value.count > 0 ? value : nil
    }

    func reIntroductionDate() -> String? {
      let value = row[Importers.WeaponHeaders.reIntroductionDate.rawValue]

      return value.count > 0 ? value : nil
    }

    func tonnage() -> Double { Double(row[Importers.WeaponHeaders.tonnage.rawValue]) ?? 0.0 }

    func criticalSlots() -> Int { Int(row[Importers.WeaponHeaders.criticalSlots.rawValue]) ?? 0 }

    func cost() -> Double { Double(row[Importers.WeaponHeaders.cost.rawValue]) ?? 0.0 }

    func battleValue() -> Double { Double(row[Importers.WeaponHeaders.battleValue.rawValue]) ?? 0.0 }

    func rulesReference() -> String { row[Importers.WeaponHeaders.rulesReference.rawValue] }

    func minimalRange() -> Int { Int(row[Importers.WeaponHeaders.minimalRange.rawValue]) ?? 0 }

    func shortRange() -> Int { Int(row[Importers.WeaponHeaders.shortRange.rawValue]) ?? 0 }

    func mediumRange() -> Int { Int(row[Importers.WeaponHeaders.mediumRange.rawValue]) ?? 0 }

    func longRange() -> Int { Int(row[Importers.WeaponHeaders.longRange.rawValue]) ?? 0 }

    func extremeRange() -> Int { Int(row[Importers.WeaponHeaders.extremeRange.rawValue]) ?? 0 }

    func shortWaterRange() -> Int { Int(row[Importers.WeaponHeaders.shortWaterRange.rawValue]) ?? 0 }

    func mediumWaterRange() -> Int { Int(row[Importers.WeaponHeaders.mediumWaterRange.rawValue]) ?? 0 }

    func longWaterRange() -> Int { Int(row[Importers.WeaponHeaders.longWaterRange.rawValue]) ?? 0 }

    func extremeWaterRange() -> Int { Int(row[Importers.WeaponHeaders.extremeWaterRange.rawValue]) ?? 0 }

    func minimalDamage() -> Int { Int(row[Importers.WeaponHeaders.minimalDamage.rawValue]) ?? 0 }

    func shortDamage() -> Int { Int(row[Importers.WeaponHeaders.shortDamage.rawValue]) ?? 0 }

    func mediumDamage() -> Int { Int(row[Importers.WeaponHeaders.mediumDamage.rawValue]) ?? 0 }

    func longDamage() -> Int { Int(row[Importers.WeaponHeaders.longDamage.rawValue]) ?? 0 }

    func extremeDamage() -> Int { Int(row[Importers.WeaponHeaders.extremeDamage.rawValue]) ?? 0 }

    func rawAlias() -> String {
      row[Importers.EquipmentHeaders.alias.rawValue].replacingOccurrences(of: self.name(), with: "")
    }

    func alias() -> [String] {
      self.rawAlias().split(
        separator: ",",
        omittingEmptySubsequences: true
      ).uniqued().map(String.init)
    }
  }
}
