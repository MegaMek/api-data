/// Defines the ``BattleTech/AmmoRulePivot`` Fluent model: the join table implementing the
/// many-to-many relationship between ammo entries and the rulebook rules that apply to them.
import Fluent
import Vapor

extension BattleTech {
    /// Fluent pivot model backing the `ammo_rule_pivot` table. Each row links one
    /// ``BattleTech/Ammo`` record to one ``BattleTech/Rule`` record; used by `Ammo.rules`
    /// (declared via `@Siblings`) to look up which rules apply to a given ammo type.
    final class AmmoRulePivot: Model, Content, @unchecked Sendable {
        static let schema = BattleTech.AmmoRulePivot.V20240327.schemaName
        public static let space: String? = BattleTech.AmmoRulePivot.V20240327.spaceName

        @ID(key: .id)
        var id: UUID?

        @Parent(key: BattleTech.AmmoRulePivot.V20240327.rule)
        var rule: BattleTech.Rule

        @Parent(key: BattleTech.AmmoRulePivot.V20240327.ammo)
        var ammo: BattleTech.Ammo

        /// Creates an empty instance for Fluent to populate when reading from the database.
        init() {}
    }
}
