/// Parses the equipment CSV file uploaded to `POST /battletech/equipment/import`
/// (handled by ``BattleTech/EquipmentController/massCreate(req:)``) into typed rows.
/// Each row is dispatched as an ``EquipmentImportJob`` payload, whose `dequeue`
/// writes it into the ``BattleTech/Equipment`` table.

/// The column order of the equipment CSV file, used as raw-value indexes into each
/// row's array of string cells.
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

/// A single row of the equipment import CSV, exposed as typed accessors over the
/// raw array of string cells (indexed via ``Importers/EquipmentHeaders``). Built by
/// ``BattleTech/EquipmentController/massCreate(req:)`` for each CSV row and queued
/// as the payload for ``EquipmentImportJob``.
extension Importers {
    struct EquipmentCSVRow: Codable {
        /// Wraps one already-split CSV row (one string per column).
        init(row: [String]) { self.row = row }

        private let row: [String]

        /// The equipment's display name.
        func name() -> String { row[Importers.EquipmentHeaders.name.rawValue] }

        /// The tech base (e.g. Inner Sphere, Clan, Mixed) as raw CSV text.
        func techBase() -> String { row[Importers.EquipmentHeaders.techBase.rawValue] }

        /// The raw, unsplit rules-reference cell (e.g. `"Rules Level/Unofficial"`).
        func rulesRaw() -> String { row[Importers.EquipmentHeaders.rules.rawValue] }

        /// The construction rules this equipment is legal under, split on `/` into
        /// individual rule names (e.g. Tournament Legal, Standard, Advanced).
        func rules() -> [String] {
            row[Importers.EquipmentHeaders.rules.rawValue].split(
                separator: "/",
                omittingEmptySubsequences: true
            ).map(String.init)
        }

        /// The tech rating letter code (e.g. `"D"`, `"F"`).
        func techRating() -> String { row[Importers.EquipmentHeaders.techRating.rawValue] }

        /// The static tech level string (e.g. `"Standard"`, `"Unofficial"`); used by
        /// callers to skip unofficial rows before importing.
        func staticTechLevel() -> String { row[Importers.EquipmentHeaders.staticTechLevel.rawValue] }

        /// The in-universe year this equipment was introduced, or `nil` if the cell
        /// is blank/missing.
        func introductionDate() -> String? {
            let value = row[Importers.EquipmentHeaders.introductionDate.rawValue]

            return value.count > 1 ? value : nil
        }

        /// The in-universe year this equipment reached prototype status, or `nil`
        /// if the cell is blank/missing.
        func prototypeDate() -> String? {
            let value = row[Importers.EquipmentHeaders.prototypeDate.rawValue]

            return value.count > 1 ? value : nil
        }

        /// The in-universe year this equipment reached full production, or `nil` if
        /// the cell is blank/missing.
        func productionDate() -> String? {
            let value = row[Importers.EquipmentHeaders.productionDate.rawValue]

            return value.count > 1 ? value : nil
        }

        /// The in-universe year this equipment became common, or `nil` if the cell
        /// is blank/missing.
        func commonDate() -> String? {
            let value = row[Importers.EquipmentHeaders.commonDate.rawValue]

            return value.count > 1 ? value : nil
        }

        /// The in-universe year this equipment went extinct, or `nil` if the cell is
        /// blank/missing.
        func extinctionDate() -> String? {
            let value = row[Importers.EquipmentHeaders.extinctionDate.rawValue]

            return value.count > 1 ? value : nil
        }

        /// The in-universe year this equipment was reintroduced after extinction,
        /// or `nil` if the cell is blank/missing.
        func reIntroductionDate() -> String? {
            let value = row[Importers.EquipmentHeaders.reIntroductionDate.rawValue]

            return value.count > 1 ? value : nil
        }

        /// The equipment's weight in tons, parsed from the CSV cell (`-1.0` if
        /// unparsable, distinguishing "unknown" from a real zero weight).
        func tonnage() -> Double { Double(row[Importers.EquipmentHeaders.tonnage.rawValue]) ?? -1.0 }

        /// The number of critical slots this equipment occupies (`-1` if
        /// unparsable).
        func criticalSlots() -> Int {
            Int(row[Importers.EquipmentHeaders.criticalSlots.rawValue]) ?? -1
        }

        /// The in-universe C-bill cost (`-1.0` if unparsable).
        func cost() -> Double { Double(row[Importers.EquipmentHeaders.cost.rawValue]) ?? -1.0 }

        /// The Battle Value contribution of this equipment (`-1.0` if unparsable).
        func battleValue() -> Double {
            Double(row[Importers.EquipmentHeaders.battleValue.rawValue]) ?? -1.0
        }

        /// The specific rulebook/page reference for this equipment.
        func rulesReference() -> String { row[Importers.EquipmentHeaders.rulesReference.rawValue] }

        /// The alias cell with this equipment's own name stripped out, leaving only
        /// the comma-separated alternate names.
        func rawAlias() -> String {
            row[Importers.EquipmentHeaders.alias.rawValue].replacingOccurrences(of: self.name(), with: "")
        }

        /// The alternate/alias names for this equipment, split, deduplicated, and
        /// trimmed of the primary name.
        func alias() -> [String] {
            self.rawAlias().split(
                separator: ",",
                omittingEmptySubsequences: true
            ).uniqued().map(String.init)
        }
    }
}
