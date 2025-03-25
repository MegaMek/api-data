extension Importers {
    enum AmmoHeaders: Int {
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
        case countAsFlak
        case munitionType
        case damagePerShot
        case rackSize
        case shots
        case ammoRatio
        case isCapital
        case kilogramPerShot
        case aeroUse
        case alias
    }
}

extension Importers {
    struct AmmoCSVRow: Codable {
        init(row: [String]) { self.row = row }

        private let row: [String]

        func name() -> String { row[Importers.AmmoHeaders.name.rawValue] }

        func techBase() -> String { row[Importers.AmmoHeaders.techBase.rawValue] }

        func rulesRaw() -> String { row[Importers.AmmoHeaders.rules.rawValue] }

        func rules() -> [String] {
            row[Importers.AmmoHeaders.rules.rawValue].split(
                separator: "/",
                omittingEmptySubsequences: true
            ).map(String.init)
        }

        func techRating() -> String { row[Importers.AmmoHeaders.techRating.rawValue] }

        func staticTechLevel() -> String { row[Importers.AmmoHeaders.staticTechLevel.rawValue] }

        func introductionDate() -> String? {
            let value = row[Importers.AmmoHeaders.introductionDate.rawValue]

            return value.count > 1 ? value : nil
        }

        func prototypeDate() -> String? {
            let value = row[Importers.AmmoHeaders.prototypeDate.rawValue]

            return value.count > 1 ? value : nil
        }

        func productionDate() -> String? {
            let value = row[Importers.AmmoHeaders.productionDate.rawValue]

            return value.count > 1 ? value : nil
        }

        func commonDate() -> String? {
            let value = row[Importers.AmmoHeaders.commonDate.rawValue]

            return value.count > 1 ? value : nil
        }

        func extinctionDate() -> String? {
            let value = row[Importers.AmmoHeaders.extinctionDate.rawValue]

            return value.count > 1 ? value : nil
        }

        func reIntroductionDate() -> String? {
            let value = row[Importers.AmmoHeaders.reIntroductionDate.rawValue]

            return value.count > 1 ? value : nil
        }

        func tonnage() -> Double { Double(row[Importers.AmmoHeaders.tonnage.rawValue]) ?? 0.0 }

        func criticalSlots() -> Int { Int(row[Importers.AmmoHeaders.criticalSlots.rawValue]) ?? 0 }

        func cost() -> Double { Double(row[Importers.AmmoHeaders.cost.rawValue]) ?? 0.0 }

        func battleValue() -> Double { Double(row[Importers.AmmoHeaders.battleValue.rawValue]) ?? 0.0 }

        func rulesReference() -> String { row[Importers.AmmoHeaders.rulesReference.rawValue] }

        func countAsFlak() -> Bool {
            let value = row[Importers.AmmoHeaders.countAsFlak.rawValue]
            return value == "TRUE"
        }

        func munitionType() -> String {
            row[Importers.AmmoHeaders.munitionType.rawValue]
                .replacingOccurrences(of: "[", with: "")
                .replacingOccurrences(of: "]", with: "")
        }

        func damagePerShot() -> Int { Int(row[Importers.AmmoHeaders.damagePerShot.rawValue]) ?? 0 }

        func rackSize() -> Int { Int(row[Importers.AmmoHeaders.rackSize.rawValue]) ?? 0 }

        func shots() -> Int { Int(row[Importers.AmmoHeaders.shots.rawValue]) ?? 0 }

        func ammoRatio() -> Double { Double(row[Importers.AmmoHeaders.ammoRatio.rawValue]) ?? 0.0 }

        func isCapital() -> Bool {
            let value = row[Importers.AmmoHeaders.countAsFlak.rawValue]
            return value == "TRUE"
        }

        func kilogramPerShot() -> Double {
            Double(row[Importers.AmmoHeaders.kilogramPerShot.rawValue]) ?? 0.0
        }

        func aeroUse() -> Bool {
            let value = row[Importers.AmmoHeaders.countAsFlak.rawValue]
            return value == "TRUE"
        }

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
