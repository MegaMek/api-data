/// Import-time helper for resolving a ``BattleTech/TechLevel`` row by name.
///
/// Used when ingesting MegaMek data files, where a tech level (e.g.
/// "Standard", "Advanced") is referenced by name and may or may not already
/// exist in the database.
import Fluent
import Vapor

extension BattleTech.TechLevel {
    /// Looks up the named tech level, creating and persisting it if it
    /// doesn't already exist.
    ///
    /// A save failure for a newly created tech level is logged rather than
    /// thrown, so the caller still receives an (unsaved) instance rather than
    /// an aborted import.
    ///
    /// - Parameters:
    ///   - tentativeTechLevel: The tech level name to look up or create, e.g.
    ///     as parsed from a MegaMek data file.
    ///   - database: The database connection to query and save against.
    /// - Returns: The matching or newly created ``BattleTech/TechLevel``.
    /// - Throws: Any error from the underlying query (save errors on a new
    ///   tech level are caught and logged, not thrown).
    static func findOrCreate(tentativeTechLevel: String, with database: Database) async throws
    -> BattleTech.TechLevel {
        if let foundTechLevel = try await BattleTech.TechLevel.query(on: database)
            .filter(\.$name == tentativeTechLevel)
            .first() {
            return foundTechLevel
        } else {
            let newTechLevel = BattleTech.TechLevel(name: tentativeTechLevel)
            do {
                try await newTechLevel.save(on: database)
            } catch {
                print(String(reflecting: error))
            }

            return newTechLevel
        }
    }
}
