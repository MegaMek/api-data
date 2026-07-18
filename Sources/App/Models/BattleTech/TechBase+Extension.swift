/// Import-time helper for resolving a ``BattleTech/TechBase`` row by name.
///
/// Used when ingesting MegaMek data files, where a tech base (e.g. "Inner
/// Sphere", "Clan") is referenced by name and may or may not already exist in
/// the database.
import Fluent
import Vapor

extension BattleTech.TechBase {
    /// Looks up the named tech base, creating and persisting it if it doesn't
    /// already exist.
    ///
    /// A save failure for a newly created tech base is logged rather than
    /// thrown, so the caller still receives an (unsaved) instance rather than
    /// an aborted import.
    ///
    /// - Parameters:
    ///   - tentativeTechBase: The tech base name to look up or create, e.g.
    ///     as parsed from a MegaMek data file.
    ///   - database: The database connection to query and save against.
    /// - Returns: The matching or newly created ``BattleTech/TechBase``.
    /// - Throws: Any error from the underlying query (save errors on a new
    ///   tech base are caught and logged, not thrown).
    static func findOrCreate(tentativeTechBase: String, with database: Database) async throws
    -> BattleTech.TechBase {
        if let foundTechBase = try await BattleTech.TechBase.query(on: database)
            .filter(\.$name == tentativeTechBase)
            .first() {
            return foundTechBase
        } else {
            let newTechBase = BattleTech.TechBase(name: tentativeTechBase)
            do {
                try await newTechBase.save(on: database)
            } catch {
                print(String(reflecting: error))
            }

            return newTechBase
        }
    }
}
