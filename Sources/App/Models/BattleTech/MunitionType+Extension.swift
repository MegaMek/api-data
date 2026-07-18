/// Helper used by the CSV importer to resolve a munition type name string into a
/// ``BattleTech/MunitionType`` record, reusing an existing one where possible.
import Fluent
import Vapor

extension BattleTech.MunitionType {
    /// Returns the existing munition type record with the given name, or creates and saves
    /// a new one if none exists yet.
    ///
    /// - Parameters:
    ///   - tentativeMunitionType: The munition type name to resolve (e.g. "Standard").
    ///   - database: The database connection to query and save through.
    /// - Returns: The found-or-created ``BattleTech/MunitionType`` record.
    /// - Throws: Rethrows any Fluent query error encountered while looking up the existing record.
    static func findOrCreate(
        tentativeMunitionType: String,
        with database: Database
    ) async throws -> BattleTech.MunitionType {
        if let foundMunitionType = try await BattleTech.MunitionType.query(on: database)
            .filter(\.$name == tentativeMunitionType)
            .first() {
            return foundMunitionType
        } else {
            let newMunitionType = BattleTech.MunitionType(name: tentativeMunitionType)
            do {
                try await newMunitionType.save(on: database)
            } catch {
                print(String(reflecting: error))
            }

            return newMunitionType
        }
    }
}
