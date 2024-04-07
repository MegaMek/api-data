import Fluent
import Vapor

extension BattleTech {
  final class FactionName: Model, Content {
    static let schema = BattleTech.FactionName.V20240316.schemaName
    public static let space: String? = BattleTech.FactionName.V20240316.spaceName

    @ID(key: .id)
    var id: UUID?

    @Field(key: BattleTech.FactionName.V20240316.name)
    var name: String

    @Field(key: BattleTech.FactionName.V20240316.startYear)
    var startYear: Int?

    @OptionalField(key: BattleTech.FactionName.V20240316.endYear)
    var endYear: Int?

    @Parent(key: BattleTech.FactionName.V20240316.faction)
    var faction: BattleTech.Faction

    init() {}

    init(
      id: UUID? = nil,
      name: String,
      startYear: Int? = nil,
      endYear: Int? = nil
    ) {
      self.id = id
      self.name = name
      self.startYear = startYear
      self.endYear = endYear
    }
  }
}
