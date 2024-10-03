import Fluent
import Vapor

extension BattleTech {
  final class AmmoRulePivot: Model, Content, @unchecked Sendable {
    static let schema = BattleTech.AmmoRulePivot.V20240327.schemaName
    public static let space: String? = BattleTech.AmmoRulePivot.V20240327.spaceName

    @ID(key: .id)
    var id: UUID?

    @Parent(key: BattleTech.AmmoRulePivot.V20240327.rule)
    var rule: BattleTech.Rule

    @Parent(key: BattleTech.AmmoRulePivot.V20240327.ammo)
    var ammo: BattleTech.Ammo

    init() {}
  }
}
