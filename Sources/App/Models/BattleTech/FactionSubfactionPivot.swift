/// Fluent model backing the `faction_subfaction` pivot table.
///
/// A pivot (join) table implements a many-to-many relationship by holding one
/// row per pairing instead of a foreign key on either side. This one links a
/// ``BattleTech/Faction`` to another ``BattleTech/Faction`` that is
/// subordinate to it, letting a single faction have many sub-factions and
/// belong to many parent factions. Consumed by the `subfactions`/`parents`
/// `@Siblings` relationships on ``BattleTech/Faction``.
import Fluent
import Vapor

// Extends the shared BattleTech namespace with the FactionSubfactionPivot model.
extension BattleTech {
    /// One faction/sub-faction pairing row in the pivot table.
    final class FactionSubfactionPivot: Model, Content, @unchecked Sendable {
        static let schema = BattleTech.FactionSubfactionPivot.V20240316.schemaName
        public static let space: String? = BattleTech.FactionSubfactionPivot.V20240316.spaceName

        @ID(key: .id)
        var id: UUID?

        // The two sides of the relationship: the parent faction and the
        // subordinate faction it contains.
        @Parent(key: BattleTech.FactionSubfactionPivot.V20240316.faction)
        var faction: BattleTech.Faction

        @Parent(key: BattleTech.FactionSubfactionPivot.V20240316.subfaction)
        var subfaction: BattleTech.Faction

        /// Empty initializer required by Fluent to hydrate model instances
        /// fetched from the database.
        init() {}
    }
}
