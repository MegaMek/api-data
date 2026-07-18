/// Helper used by the CSV importer to resolve a batch of alias name strings into
/// ``BattleTech/AmmoAlias`` records, reusing existing ones where possible.
import Fluent
import Vapor

extension BattleTech.AmmoAlias {
    /// For each given name, returns the existing alias record with that name, or builds a
    /// new (unsaved) one if none exists yet.
    ///
    /// - Parameters:
    ///   - tentativeAliases: The alias name strings to resolve.
    ///   - database: The database connection to query through.
    /// - Returns: One ``BattleTech/AmmoAlias`` per input name, in the same order.
    /// - Throws: Rethrows any Fluent query errors encountered while looking up existing aliases.
    static func findOrCreate(
        tentativeAliases: [String],
        with database: Database
    ) async throws -> [BattleTech.AmmoAlias] {
        var aliases: [BattleTech.AmmoAlias] = []

        for alias in tentativeAliases {
            if let foundAlias = try await BattleTech.AmmoAlias.query(on: database)
                .filter(\.$name == alias)
                .first() {
                aliases.append(foundAlias)
            } else {
                let newAlias = BattleTech.AmmoAlias(name: alias)
                aliases.append(newAlias)
            }
        }

        return aliases
    }
}
