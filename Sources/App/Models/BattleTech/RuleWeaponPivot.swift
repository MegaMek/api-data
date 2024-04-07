import Fluent
import Vapor

extension BattleTech {
  final class RuleWeaponPivot: Model, Content {
    static let schema = BattleTech.RuleWeaponPivot.V20240316.schemaName
    public static let space: String? = BattleTech.RuleWeaponPivot.V20240316.spaceName

    @ID(key: .id)
    var id: UUID?

    @Parent(key: BattleTech.RuleWeaponPivot.V20240316.rule)
    var rule: BattleTech.Rule

    @Parent(key: BattleTech.RuleWeaponPivot.V20240316.weapon)
    var weapon: BattleTech.Weapon

    init() {}
  }
}
