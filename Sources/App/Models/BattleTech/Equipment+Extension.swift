/// Helper methods used by the CSV data importer to create/update ``BattleTech/Equipment``
/// records and their related tech-base, tech-level, rule, and alias associations.
import Fluent
import Vapor

extension BattleTech.Equipment {
    /// Finds an existing equipment record matching the CSV row, or creates a new one, then
    /// overwrites it with the row's data and persists it.
    ///
    /// - Parameters:
    ///   - csvRow: The parsed equipment CSV row to import.
    ///   - database: The database connection to query and save through.
    /// - Returns: The found-or-created, now up-to-date ``BattleTech/Equipment`` record.
    /// - Throws: Rethrows any Fluent query/save errors encountered while matching or updating.
    static func findOrCreate(
        csvRow: Importers.EquipmentCSVRow,
        on database: Database
    ) async throws -> BattleTech.Equipment {
        var equipment: BattleTech.Equipment? = BattleTech.Equipment()

        if let foundEquipment = try await BattleTech.Equipment.findByNameOrAliases(
            name: csvRow.name(),
            aliases: csvRow.alias(),
            csvRow: csvRow,
            on: database
        ) {
            equipment = foundEquipment
        }

        do {
            try await equipment?.updateFromCSVRow(csvRow: csvRow, on: database)
            try await equipment?.save(on: database)
        } catch {
            print(String(reflecting: error))
        }

        return equipment!
    }

    /// Looks up an equipment record whose name matches exactly, or whose name matches one of
    /// the given aliases, while also matching on tech rating, tonnage, tech level, and tech
    /// base (resolving/creating those lookup records as needed).
    ///
    /// - Parameters:
    ///   - name: The equipment name to match exactly.
    ///   - aliases: Alternate names to match against if an exact name match isn't found.
    ///   - csvRow: The CSV row supplying the tech rating, tonnage, tech level, and tech base to match on.
    ///   - database: The database connection to query through.
    /// - Returns: The matching ``BattleTech/Equipment`` record, or `nil` if none matches.
    /// - Throws: Rethrows any Fluent query errors encountered while resolving lookups or matching.
    static func findByNameOrAliases(
        name: String,
        aliases: [String],
        csvRow: Importers.EquipmentCSVRow,
        on database: Database
    ) async throws -> BattleTech.Equipment? {

        let techLevel = try await BattleTech.TechLevel.findOrCreate(
            tentativeTechLevel: csvRow.staticTechLevel(),
            with: database
        )

        let techBase = try await BattleTech.TechBase.findOrCreate(
            tentativeTechBase: csvRow.techBase(),
            with: database
        )

        if let foundByName = try await BattleTech.Equipment.query(on: database)
            .filter(\.$name == csvRow.name())
            .filter(\.$techRating == csvRow.techRating())
            .filter(\.$tonnage == csvRow.tonnage())
            .filter(\.$techLevelStatic.$id == techLevel.id!)
            .filter(\.$techBase.$id == techBase.id!)
            .first() {
            return foundByName
        }

        if let foundByAliases = try await BattleTech.Equipment.query(on: database)
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

    /// Resolves (or creates) the named tech base and sets this equipment's foreign key to it.
    ///
    /// - Parameters:
    ///   - techBase: Name of the tech base (e.g. Inner Sphere, Clan) to attach.
    ///   - database: The database connection to query and save through.
    /// - Throws: Rethrows any Fluent query/save errors from ``BattleTech/TechBase/findOrCreate(tentativeTechBase:with:)``.
    func attachTechBase(techBase: String, on database: Database) async throws {
        let record = try await BattleTech.TechBase.findOrCreate(
            tentativeTechBase: techBase,
            with: database
        )

        self.$techBase.id = record.id!
    }

    /// Resolves (or creates) the named tech level and sets this equipment's foreign key to it.
    ///
    /// - Parameters:
    ///   - techLevel: Name of the tech level to attach.
    ///   - database: The database connection to query and save through.
    /// - Throws: Rethrows any Fluent query/save errors from ``BattleTech/TechLevel/findOrCreate(tentativeTechLevel:with:)``.
    func attachTechLevel(techLevel: String, on database: Database) async throws {
        let record = try await BattleTech.TechLevel.findOrCreate(
            tentativeTechLevel: techLevel,
            with: database
        )

        self.$techLevelStatic.id = record.id!
    }

    /// Resolves (or creates) each named rule and attaches it to this equipment via the
    /// many-to-many rules relationship, skipping any that are already attached.
    ///
    /// - Parameters:
    ///   - rules: Names of the rules to attach.
    ///   - database: The database connection to query and save through.
    /// - Throws: Rethrows any Fluent query errors from ``BattleTech/Rule/findOrCreate(tentativeRules:with:)``.
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

    /// Resolves (or creates) each named alias and links it to this equipment record so the
    /// alternate name can be used to find this equipment again in future imports.
    ///
    /// - Parameters:
    ///   - aliases: Alternate names to attach to this equipment.
    ///   - database: The database connection to query and save through.
    /// - Throws: Rethrows any Fluent query errors from ``BattleTech/EquipmentAlias/findOrCreate(tentativeAliases:with:)``.
    func attachAliases(aliases: [String], on database: Database) async throws {
        let records = try await BattleTech.EquipmentAlias.findOrCreate(
            tentativeAliases: aliases,
            with: database
        )

        for alias in records {
            alias.$equipment.id = self.id!
            do {
                try await alias.save(on: database)
            } catch {
                print(String(reflecting: error))
            }
        }

    }

    /// Overwrites this equipment's scalar fields from the CSV row, saves it, then attaches
    /// its tech base, tech level, rules, and aliases.
    ///
    /// - Parameters:
    ///   - csvRow: The parsed equipment CSV row supplying the new field values.
    ///   - database: The database connection to save and attach related records through.
    /// - Throws: Rethrows any Fluent save error from persisting this record.
    func updateFromCSVRow(csvRow: Importers.EquipmentCSVRow, on database: Database) async throws {
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
