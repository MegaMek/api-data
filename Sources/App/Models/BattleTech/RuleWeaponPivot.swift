/// Fluent model backing the `rule_weapon` pivot table.
///
/// Pivot (join) table implementing the many-to-many relationship between
/// ``BattleTech/Rule`` and ``BattleTech/Weapon``: one row per rule/weapon
/// pairing, since a rule can apply to many weapons and a weapon can be
/// governed by many rules. Consumed by the `weapons` `@Siblings` relationship
/// on ``BattleTech/Rule``.
import Fluent
import Vapor

// Extends the shared BattleTech namespace with the RuleWeaponPivot model.
extension BattleTech {
    /// One rule/weapon pairing row in the pivot table.
    final class RuleWeaponPivot: Model, Content, @unchecked Sendable {
        static let schema = BattleTech.RuleWeaponPivot.V20240316.schemaName
        public static let space: String? = BattleTech.RuleWeaponPivot.V20240316.spaceName

        @ID(key: .id)
        var id: UUID?

        // The two sides of the relationship: the rule and the weapon it
        // applies to.
        @Parent(key: BattleTech.RuleWeaponPivot.V20240316.rule)
        var rule: BattleTech.Rule

        @Parent(key: BattleTech.RuleWeaponPivot.V20240316.weapon)
        var weapon: BattleTech.Weapon

        /// Empty initializer required by Fluent to hydrate model instances
        /// fetched from the database.
        init() {}
    }
}
