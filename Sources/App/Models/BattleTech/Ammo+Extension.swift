/// Helper methods used by the CSV data importer to create/update ``BattleTech/Ammo`` records
/// and their related tech-base, tech-level, munition-type, rule, and alias associations.
import Fluent
import Vapor

extension BattleTech.Ammo {
    /// Finds an existing ammo record matching the CSV row, or creates a new one, then
    /// overwrites it with the row's data and persists it.
    ///
    /// - Parameters:
    ///   - csvRow: The parsed ammo CSV row to import.
    ///   - database: The database connection to query and save through.
    /// - Returns: The found-or-created, now up-to-date ``BattleTech/Ammo`` record.
    /// - Throws: Rethrows any Fluent query/save errors encountered while matching or updating.
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

    /// Looks up an ammo record whose name matches exactly, or whose name matches one of the
    /// given aliases, while also matching on tech rating, tonnage, tech level, and tech base
    /// (resolving/creating those lookup records as needed).
    ///
    /// - Parameters:
    ///   - name: The ammo name to match exactly.
    ///   - aliases: Alternate names to match against if an exact name match isn't found.
    ///   - csvRow: The CSV row supplying the tech rating, tonnage, tech level, and tech base to match on.
    ///   - database: The database connection to query through.
    /// - Returns: The matching ``BattleTech/Ammo`` record, or `nil` if none matches.
    /// - Throws: Rethrows any Fluent query errors encountered while resolving lookups or matching.
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

    /// Resolves (or creates) the named tech base and sets this ammo's foreign key to it.
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

    /// Resolves (or creates) the named tech level and sets this ammo's foreign key to it.
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

    /// Resolves (or creates) the named munition type and sets this ammo's foreign key to it.
    ///
    /// - Parameters:
    ///   - munitionType: Name of the munition type (e.g. Standard, Inferno, Cluster) to attach.
    ///   - database: The database connection to query and save through.
    /// - Throws: Rethrows any Fluent query/save errors from ``BattleTech/MunitionType/findOrCreate(tentativeMunitionType:with:)``.
    func attachMunitionType(munitionType: String, on database: Database) async throws {
        let record = try await BattleTech.MunitionType.findOrCreate(
            tentativeMunitionType: munitionType,
            with: database
        )

        self.$munitionType.id = record.id!
    }

    /// Resolves (or creates) each named rule and attaches it to this ammo via the
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

    /// Resolves (or creates) each named alias and links it to this ammo record so the
    /// alternate name can be used to find this ammo again in future imports.
    ///
    /// - Parameters:
    ///   - aliases: Alternate names to attach to this ammo.
    ///   - database: The database connection to query and save through.
    /// - Throws: Rethrows any Fluent query errors from ``BattleTech/AmmoAlias/findOrCreate(tentativeAliases:with:)``.
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

    /// Overwrites this ammo's scalar fields from the CSV row, saves it, then attaches its
    /// tech base, tech level, munition type, rules, and aliases.
    ///
    /// - Parameters:
    ///   - csvRow: The parsed ammo CSV row supplying the new field values.
    ///   - database: The database connection to save and attach related records through.
    /// - Throws: Rethrows any Fluent save error from persisting this record.
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
