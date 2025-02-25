import Fluent
import Vapor

extension BattleTech {
    final class EquipmentRulePivot: Model, Content, @unchecked Sendable {
        static let schema = BattleTech.EquipmentRulePivot.V20240330.schemaName
        public static let space: String? = BattleTech.EquipmentRulePivot.V20240330.spaceName

        @ID(key: .id)
        var id: UUID?

        @Parent(key: BattleTech.EquipmentRulePivot.V20240330.rule)
        var rule: BattleTech.Rule

        @Parent(key: BattleTech.EquipmentRulePivot.V20240330.equipment)
        var equipment: BattleTech.Equipment

        init() {}
    }
}
