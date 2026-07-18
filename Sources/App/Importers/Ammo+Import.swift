/// Parses the ammo CSV file uploaded to `POST /battletech/ammo/import` (handled by
/// ``BattleTech/AmmoController/massCreate(req:)``) into typed rows. Each row is
/// dispatched as an ``AmmoImportJob`` payload, whose `dequeue` writes it into the
/// ``BattleTech/Ammo`` table.

/// The column order of the ammo CSV file, used as raw-value indexes into each row's
/// array of string cells.
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

/// A single row of the ammo import CSV, exposed as typed accessors over the raw
/// array of string cells (indexed via ``Importers/AmmoHeaders``). Built by
/// ``BattleTech/AmmoController/massCreate(req:)`` for each CSV row and queued as
/// the payload for ``AmmoImportJob``.
extension Importers {
    struct AmmoCSVRow: Codable {
        /// Wraps one already-split CSV row (one string per column).
        init(row: [String]) { self.row = row }

        private let row: [String]

        /// The ammo's display name.
        func name() -> String { row[Importers.AmmoHeaders.name.rawValue] }

        /// The tech base (e.g. Inner Sphere, Clan, Mixed) as raw CSV text.
        func techBase() -> String { row[Importers.AmmoHeaders.techBase.rawValue] }

        /// The raw, unsplit rules-reference cell (e.g. `"Rules Level/Unofficial"`).
        func rulesRaw() -> String { row[Importers.AmmoHeaders.rules.rawValue] }

        /// The construction rules this ammo is legal under, split on `/` into
        /// individual rule names (e.g. Tournament Legal, Standard, Advanced).
        func rules() -> [String] {
            row[Importers.AmmoHeaders.rules.rawValue].split(
                separator: "/",
                omittingEmptySubsequences: true
            ).map(String.init)
        }

        /// The tech rating letter code (e.g. `"D"`, `"F"`).
        func techRating() -> String { row[Importers.AmmoHeaders.techRating.rawValue] }

        /// The static tech level string (e.g. `"Standard"`, `"Unofficial"`); used by
        /// callers to skip unofficial rows before importing.
        func staticTechLevel() -> String { row[Importers.AmmoHeaders.staticTechLevel.rawValue] }

        /// The in-universe year this ammo was introduced, or `nil` if the cell is
        /// blank/missing.
        func introductionDate() -> String? {
            let value = row[Importers.AmmoHeaders.introductionDate.rawValue]

            return value.count > 1 ? value : nil
        }

        /// The in-universe year this ammo reached prototype status, or `nil` if the
        /// cell is blank/missing.
        func prototypeDate() -> String? {
            let value = row[Importers.AmmoHeaders.prototypeDate.rawValue]

            return value.count > 1 ? value : nil
        }

        /// The in-universe year this ammo reached full production, or `nil` if the
        /// cell is blank/missing.
        func productionDate() -> String? {
            let value = row[Importers.AmmoHeaders.productionDate.rawValue]

            return value.count > 1 ? value : nil
        }

        /// The in-universe year this ammo became common, or `nil` if the cell is
        /// blank/missing.
        func commonDate() -> String? {
            let value = row[Importers.AmmoHeaders.commonDate.rawValue]

            return value.count > 1 ? value : nil
        }

        /// The in-universe year this ammo went extinct, or `nil` if the cell is
        /// blank/missing.
        func extinctionDate() -> String? {
            let value = row[Importers.AmmoHeaders.extinctionDate.rawValue]

            return value.count > 1 ? value : nil
        }

        /// The in-universe year this ammo was reintroduced after extinction, or
        /// `nil` if the cell is blank/missing.
        func reIntroductionDate() -> String? {
            let value = row[Importers.AmmoHeaders.reIntroductionDate.rawValue]

            return value.count > 1 ? value : nil
        }

        /// The ammo's weight in tons, parsed from the CSV cell (`0.0` if unparsable).
        func tonnage() -> Double { Double(row[Importers.AmmoHeaders.tonnage.rawValue]) ?? 0.0 }

        /// The number of critical slots this ammo occupies (`0` if unparsable).
        func criticalSlots() -> Int { Int(row[Importers.AmmoHeaders.criticalSlots.rawValue]) ?? 0 }

        /// The in-universe C-bill cost (`0.0` if unparsable).
        func cost() -> Double { Double(row[Importers.AmmoHeaders.cost.rawValue]) ?? 0.0 }

        /// The Battle Value contribution of this ammo (`0.0` if unparsable).
        func battleValue() -> Double { Double(row[Importers.AmmoHeaders.battleValue.rawValue]) ?? 0.0 }

        /// The specific rulebook/page reference for this ammo.
        func rulesReference() -> String { row[Importers.AmmoHeaders.rulesReference.rawValue] }

        /// Whether this ammo counts as flak for anti-aircraft purposes.
        func countAsFlak() -> Bool {
            let value = row[Importers.AmmoHeaders.countAsFlak.rawValue]
            return value == "TRUE"
        }

        /// The munition type name (e.g. `"Standard"`, `"Cluster"`), with the CSV's
        /// surrounding square brackets stripped.
        func munitionType() -> String {
            row[Importers.AmmoHeaders.munitionType.rawValue]
                .replacingOccurrences(of: "[", with: "")
                .replacingOccurrences(of: "]", with: "")
        }

        /// Damage dealt per shot fired (`0` if unparsable).
        func damagePerShot() -> Int { Int(row[Importers.AmmoHeaders.damagePerShot.rawValue]) ?? 0 }

        /// The weapon rack size this ammo is sized for (`0` if unparsable).
        func rackSize() -> Int { Int(row[Importers.AmmoHeaders.rackSize.rawValue]) ?? 0 }

        /// The number of shots per ton of ammo (`0` if unparsable).
        func shots() -> Int { Int(row[Importers.AmmoHeaders.shots.rawValue]) ?? 0 }

        /// The ammo-to-weapon ratio used in some construction rules (`0.0` if
        /// unparsable).
        func ammoRatio() -> Double { Double(row[Importers.AmmoHeaders.ammoRatio.rawValue]) ?? 0.0 }

        /// Whether this is capital-scale ammo.
        func isCapital() -> Bool {
            let value = row[Importers.AmmoHeaders.isCapital.rawValue]
            return value == "TRUE"
        }

        /// Mass per shot in kilograms, for ammo types measured that way (`0.0` if
        /// unparsable).
        func kilogramPerShot() -> Double {
            Double(row[Importers.AmmoHeaders.kilogramPerShot.rawValue]) ?? 0.0
        }

        /// Whether this ammo is usable by aerospace units.
        func aeroUse() -> Bool {
            let value = row[Importers.AmmoHeaders.aeroUse.rawValue]
            return value == "TRUE"
        }

        /// The alias cell with this ammo's own name stripped out, leaving only the
        /// comma-separated alternate names.
        func rawAlias() -> String {
            row[Importers.EquipmentHeaders.alias.rawValue].replacingOccurrences(of: self.name(), with: "")
        }

        /// The alternate/alias names for this ammo, split, deduplicated, and
        /// trimmed of the primary name.
        func alias() -> [String] {
            self.rawAlias().split(
                separator: ",",
                omittingEmptySubsequences: true
            ).uniqued().map(String.init)
        }
    }
}
