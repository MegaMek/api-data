import Fluent
import Vapor

extension BattleTech {
  final class FactionSubfactionPivot: Model, Content {
    static let schema = BattleTech.FactionSubfactionPivot.V20240316.schemaName
    public static let space: String? = BattleTech.FactionSubfactionPivot.V20240316.spaceName

    @ID(key: .id)
    var id: UUID?

    @Parent(key: BattleTech.FactionSubfactionPivot.V20240316.faction)
    var faction: BattleTech.Faction

    @Parent(key: BattleTech.FactionSubfactionPivot.V20240316.subfaction)
    var subfaction: BattleTech.Faction

    init() {}
  }
}
