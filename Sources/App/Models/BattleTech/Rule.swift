import Fluent
import Vapor

extension BattleTech {
    final class Rule: Model, Content, @unchecked Sendable {
        static let schema = BattleTech.Rule.V20240316.schemaName
        public static let space: String? = BattleTech.Rule.V20240316.spaceName

        @ID(key: .id)
        var id: UUID?

        @Field(key: BattleTech.Rule.V20240316.name)
        var name: String

        @Siblings(through: BattleTech.AmmoRulePivot.self, from: \.$rule, to: \.$ammo)
        var ammo: [BattleTech.Ammo]

        @Siblings(through: BattleTech.EquipmentRulePivot.self, from: \.$rule, to: \.$equipment)
        var equipment: [BattleTech.Equipment]

        @Siblings(through: BattleTech.RuleWeaponPivot.self, from: \.$rule, to: \.$weapon)
        var weapons: [BattleTech.Weapon]

        init() {}

        init(id: UUID? = nil, name: String) {
            self.id = id
            self.name = name
        }
    }
}
