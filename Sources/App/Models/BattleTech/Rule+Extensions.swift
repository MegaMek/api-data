/// Import-time helper for resolving ``BattleTech/Rule`` rows by name.
///
/// Used when ingesting MegaMek data files, where rules are referenced by
/// their name string and may or may not already exist in the database.
import Fluent
import Vapor

extension BattleTech.Rule {
    /// Looks up each named rule, creating and persisting any that don't
    /// already exist, so callers always get back a fully-populated rule for
    /// every name given.
    ///
    /// Save failures for newly created rules are logged rather than thrown,
    /// so a bad row does not abort the whole batch; the rule is still
    /// returned unsaved in that case.
    ///
    /// - Parameters:
    ///   - tentativeRules: Rule names to look up or create, e.g. as parsed
    ///     from a MegaMek data file.
    ///   - database: The database connection to query and save against.
    /// - Returns: One ``BattleTech/Rule`` per entry in `tentativeRules`, in
    ///   the same order, either fetched from existing rows or newly created.
    /// - Throws: Any error from the underlying query (save errors on new
    ///   rules are caught and logged, not thrown).
    static func findOrCreate(tentativeRules: [String], with database: Database) async throws
    -> [BattleTech.Rule] {
        var rules: [BattleTech.Rule] = []

        for rule in tentativeRules {
            if let foundRule = try await BattleTech.Rule.query(on: database)
                .filter(\.$name == rule)
                .first() {
                rules.append(foundRule)
            } else {
                let newRule = BattleTech.Rule(name: rule)
                do {
                    try await newRule.save(on: database)
                } catch {
                    print(String(reflecting: error))
                }

                rules.append(newRule)
            }
        }

        return rules
    }
}
