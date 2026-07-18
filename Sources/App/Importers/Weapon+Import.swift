/// Parses the weapon CSV file uploaded to `POST /battletech/weapons/import`
/// (handled by ``BattleTech/WeaponController/massCreate(req:)``) into typed rows.
/// Each row is dispatched as a ``WeaponImportJob`` payload, whose `dequeue` writes
/// it into the ``BattleTech/Weapon`` table.

/// The column order of the weapon CSV file, used as raw-value indexes into each
/// row's array of string cells.
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

/// A single row of the weapon import CSV, exposed as typed accessors over the raw
/// array of string cells (indexed via ``Importers/WeaponHeaders``). Built by
/// ``BattleTech/WeaponController/massCreate(req:)`` for each CSV row and queued as
/// the payload for ``WeaponImportJob``.
extension Importers {
    struct WeaponCSVRow: Codable {
        /// Wraps one already-split CSV row (one string per column).
        init(row: [String]) { self.row = row }

        private let row: [String]

        /// The weapon's display name.
        func name() -> String { row[Importers.WeaponHeaders.name.rawValue] }

        /// The tech base (e.g. Inner Sphere, Clan, Mixed) as raw CSV text.
        func techBase() -> String { row[Importers.WeaponHeaders.techBase.rawValue] }

        /// The raw, unsplit rules-reference cell (e.g. `"Rules Level/Unofficial"`).
        func rulesRaw() -> String { row[Importers.WeaponHeaders.rules.rawValue] }

        /// The construction rules this weapon is legal under, split on `/` into
        /// individual rule names (e.g. Tournament Legal, Standard, Advanced).
        func rules() -> [String] {
            row[Importers.WeaponHeaders.rules.rawValue].split(
                separator: "/",
                omittingEmptySubsequences: true
            ).map(String.init)
        }

        /// The tech rating letter code (e.g. `"D"`, `"F"`).
        func techRating() -> String { row[Importers.WeaponHeaders.techRating.rawValue] }

        /// The static tech level string (e.g. `"Standard"`, `"Unofficial"`); used by
        /// callers to skip unofficial rows before importing.
        func staticTechLevel() -> String { row[Importers.WeaponHeaders.staticTechLevel.rawValue] }

        /// The in-universe year this weapon was introduced, or `nil` if the cell is
        /// empty.
        func introductionDate() -> String? {
            let value = row[Importers.WeaponHeaders.introductionDate.rawValue]

            return value.count > 0 ? value : nil
        }

        /// The in-universe year this weapon reached prototype status, or `nil` if
        /// the cell is empty.
        func prototypeDate() -> String? {
            let value = row[Importers.WeaponHeaders.prototypeDate.rawValue]

            return value.count > 0 ? value : nil
        }

        /// The in-universe year this weapon reached full production, or `nil` if
        /// the cell is empty.
        func productionDate() -> String? {
            let value = row[Importers.WeaponHeaders.productionDate.rawValue]

            return value.count > 0 ? value : nil
        }

        /// The in-universe year this weapon became common, or `nil` if the cell is
        /// empty.
        func commonDate() -> String? {
            let value = row[Importers.WeaponHeaders.commonDate.rawValue]

            return value.count > 0 ? value : nil
        }

        /// The in-universe year this weapon went extinct, or `nil` if the cell is
        /// empty.
        func extinctionDate() -> String? {
            let value = row[Importers.WeaponHeaders.extinctionDate.rawValue]

            return value.count > 0 ? value : nil
        }

        /// The in-universe year this weapon was reintroduced after extinction, or
        /// `nil` if the cell is empty.
        func reIntroductionDate() -> String? {
            let value = row[Importers.WeaponHeaders.reIntroductionDate.rawValue]

            return value.count > 0 ? value : nil
        }

        /// The weapon's weight in tons, parsed from the CSV cell (`0.0` if
        /// unparsable).
        func tonnage() -> Double { Double(row[Importers.WeaponHeaders.tonnage.rawValue]) ?? 0.0 }

        /// The number of critical slots this weapon occupies (`0` if unparsable).
        func criticalSlots() -> Int { Int(row[Importers.WeaponHeaders.criticalSlots.rawValue]) ?? 0 }

        /// The in-universe C-bill cost (`0.0` if unparsable).
        func cost() -> Double { Double(row[Importers.WeaponHeaders.cost.rawValue]) ?? 0.0 }

        /// The Battle Value contribution of this weapon (`0.0` if unparsable).
        func battleValue() -> Double {
            Double(row[Importers.WeaponHeaders.battleValue.rawValue]) ?? 0.0
        }

        /// The specific rulebook/page reference for this weapon.
        func rulesReference() -> String { row[Importers.WeaponHeaders.rulesReference.rawValue] }

        /// The minimum effective range in hexes (`0` if unparsable).
        func minimalRange() -> Int { Int(row[Importers.WeaponHeaders.minimalRange.rawValue]) ?? 0 }

        /// The short-range bracket distance in hexes (`0` if unparsable).
        func shortRange() -> Int { Int(row[Importers.WeaponHeaders.shortRange.rawValue]) ?? 0 }

        /// The medium-range bracket distance in hexes (`0` if unparsable).
        func mediumRange() -> Int { Int(row[Importers.WeaponHeaders.mediumRange.rawValue]) ?? 0 }

        /// The long-range bracket distance in hexes (`0` if unparsable).
        func longRange() -> Int { Int(row[Importers.WeaponHeaders.longRange.rawValue]) ?? 0 }

        /// The extreme-range bracket distance in hexes (`0` if unparsable).
        func extremeRange() -> Int { Int(row[Importers.WeaponHeaders.extremeRange.rawValue]) ?? 0 }

        /// The short-range bracket distance in hexes when fired underwater (`0` if
        /// unparsable).
        func shortWaterRange() -> Int {
            Int(row[Importers.WeaponHeaders.shortWaterRange.rawValue]) ?? 0
        }

        /// The medium-range bracket distance in hexes when fired underwater (`0` if
        /// unparsable).
        func mediumWaterRange() -> Int {
            Int(row[Importers.WeaponHeaders.mediumWaterRange.rawValue]) ?? 0
        }

        /// The long-range bracket distance in hexes when fired underwater (`0` if
        /// unparsable).
        func longWaterRange() -> Int { Int(row[Importers.WeaponHeaders.longWaterRange.rawValue]) ?? 0 }

        /// The extreme-range bracket distance in hexes when fired underwater (`0`
        /// if unparsable).
        func extremeWaterRange() -> Int {
            Int(row[Importers.WeaponHeaders.extremeWaterRange.rawValue]) ?? 0
        }

        /// Damage dealt at minimal range (`0` if unparsable).
        func minimalDamage() -> Int { Int(row[Importers.WeaponHeaders.minimalDamage.rawValue]) ?? 0 }

        /// Damage dealt at short range (`0` if unparsable).
        func shortDamage() -> Int { Int(row[Importers.WeaponHeaders.shortDamage.rawValue]) ?? 0 }

        /// Damage dealt at medium range (`0` if unparsable).
        func mediumDamage() -> Int { Int(row[Importers.WeaponHeaders.mediumDamage.rawValue]) ?? 0 }

        /// Damage dealt at long range (`0` if unparsable).
        func longDamage() -> Int { Int(row[Importers.WeaponHeaders.longDamage.rawValue]) ?? 0 }

        /// Damage dealt at extreme range (`0` if unparsable).
        func extremeDamage() -> Int { Int(row[Importers.WeaponHeaders.extremeDamage.rawValue]) ?? 0 }

        /// The alias cell with this weapon's own name stripped out, leaving only
        /// the comma-separated alternate names.
        func rawAlias() -> String {
            row[Importers.EquipmentHeaders.alias.rawValue].replacingOccurrences(of: self.name(), with: "")
        }

        /// The alternate/alias names for this weapon, split, deduplicated, and
        /// trimmed of the primary name.
        func alias() -> [String] {
            self.rawAlias().split(
                separator: ",",
                omittingEmptySubsequences: true
            ).uniqued().map(String.init)
        }
    }
}
