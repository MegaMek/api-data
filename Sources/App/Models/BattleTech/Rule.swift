/// Fluent model backing the `rules` table.
///
/// A named tabletop ruleset/tag (e.g. "Standard", "Advanced", "Introductory")
/// that governs which pieces of equipment are legal to use together. Rules
/// are linked to ``BattleTech/Ammo``, `Equipment`, and ``BattleTech/Weapon``
/// through pivot tables, since any of those can be tagged with many rules and
/// any rule can apply to many items.
import Fluent
import Vapor

// Extends the shared BattleTech namespace with the Rule model.
extension BattleTech {
    /// One named ruleset that applies to a set of ammo, equipment, and weapons.
    final class Rule: Model, Content, @unchecked Sendable {
        static let schema = BattleTech.Rule.V20240316.schemaName
        public static let space: String? = BattleTech.Rule.V20240316.spaceName

        @ID(key: .id)
        var id: UUID?

        @Field(key: BattleTech.Rule.V20240316.name)
        var name: String

        // Many-to-many relationships to the item types this rule applies to,
        // each backed by its own pivot table (e.g. BattleTech.RuleWeaponPivot).
        @Siblings(through: BattleTech.AmmoRulePivot.self, from: \.$rule, to: \.$ammo)
        var ammo: [BattleTech.Ammo]

        @Siblings(through: BattleTech.EquipmentRulePivot.self, from: \.$rule, to: \.$equipment)
        var equipment: [BattleTech.Equipment]

        @Siblings(through: BattleTech.RuleWeaponPivot.self, from: \.$rule, to: \.$weapon)
        var weapons: [BattleTech.Weapon]

        /// Empty initializer required by Fluent to hydrate model instances
        /// fetched from the database.
        init() {}

        /// Creates a new Rule with the given name.
        ///
        /// - Parameters:
        ///   - id: Optional database identifier; `nil` for a not-yet-persisted
        ///     rule.
        ///   - name: The rule's unique display name.
        init(id: UUID? = nil, name: String) {
            self.id = id
            self.name = name
        }
    }
}
