/// Defines the ``BattleTech/EquipmentRulePivot`` Fluent model: the join table implementing
/// the many-to-many relationship between equipment entries and the rulebook rules that apply
/// to them.
import Fluent
import Vapor

extension BattleTech {
    /// Fluent pivot model backing the `equipment_rule_pivot` table. Each row links one
    /// ``BattleTech/Equipment`` record to one ``BattleTech/Rule`` record; used by
    /// `Equipment.rules` (declared via `@Siblings`) to look up which rules apply to a given
    /// piece of equipment.
    final class EquipmentRulePivot: Model, Content, @unchecked Sendable {
        static let schema = BattleTech.EquipmentRulePivot.V20240330.schemaName
        public static let space: String? = BattleTech.EquipmentRulePivot.V20240330.spaceName

        @ID(key: .id)
        var id: UUID?

        @Parent(key: BattleTech.EquipmentRulePivot.V20240330.rule)
        var rule: BattleTech.Rule

        @Parent(key: BattleTech.EquipmentRulePivot.V20240330.equipment)
        var equipment: BattleTech.Equipment

        /// Creates an empty instance for Fluent to populate when reading from the database.
        init() {}
    }
}
