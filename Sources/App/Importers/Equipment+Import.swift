extension Importers {
  enum EquipmentHeaders: Int {
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
    case alias
  }
}

extension Importers {
    struct EquipmentCSVRow: Codable {
    init(row: [String]) { self.row = row }

    private let row: [String]

    func name() -> String { row[Importers.EquipmentHeaders.name.rawValue] }

    func techBase() -> String { row[Importers.EquipmentHeaders.techBase.rawValue] }

    func rulesRaw() -> String { row[Importers.EquipmentHeaders.rules.rawValue] }

    func rules() -> [String] {
      row[Importers.EquipmentHeaders.rules.rawValue].split(
        separator: "/",
        omittingEmptySubsequences: true
      ).map(String.init)
    }

    func techRating() -> String { row[Importers.EquipmentHeaders.techRating.rawValue] }

    func staticTechLevel() -> String { row[Importers.EquipmentHeaders.staticTechLevel.rawValue] }

    func introductionDate() -> String? {
      let value = row[Importers.EquipmentHeaders.introductionDate.rawValue]

      return value.count > 1 ? value : nil
    }

    func prototypeDate() -> String? {
      let value = row[Importers.EquipmentHeaders.prototypeDate.rawValue]

      return value.count > 1 ? value : nil
    }

    func productionDate() -> String? {
      let value = row[Importers.EquipmentHeaders.productionDate.rawValue]

      return value.count > 1 ? value : nil
    }

    func commonDate() -> String? {
      let value = row[Importers.EquipmentHeaders.commonDate.rawValue]

      return value.count > 1 ? value : nil
    }

    func extinctionDate() -> String? {
      let value = row[Importers.EquipmentHeaders.extinctionDate.rawValue]

      return value.count > 1 ? value : nil
    }

    func reIntroductionDate() -> String? {
      let value = row[Importers.EquipmentHeaders.reIntroductionDate.rawValue]

      return value.count > 1 ? value : nil
    }

    func tonnage() -> Double { Double(row[Importers.EquipmentHeaders.tonnage.rawValue]) ?? -1.0 }

    func criticalSlots() -> Int {
      Int(row[Importers.EquipmentHeaders.criticalSlots.rawValue]) ?? -1
    }

    func cost() -> Double { Double(row[Importers.EquipmentHeaders.cost.rawValue]) ?? -1.0 }

    func battleValue() -> Double {
      Double(row[Importers.EquipmentHeaders.battleValue.rawValue]) ?? -1.0
    }

    func rulesReference() -> String { row[Importers.EquipmentHeaders.rulesReference.rawValue] }

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
