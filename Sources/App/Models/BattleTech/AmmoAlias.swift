import Fluent
import Vapor

extension BattleTech {
  final class AmmoAlias: Model, Content {
    static let schema = BattleTech.AmmoAlias.V20240327.schemaName
    public static let space: String? = BattleTech.AmmoAlias.V20240327.spaceName

    @ID(key: .id)
    var id: UUID?

    @Field(key: BattleTech.AmmoAlias.V20240327.name)
    var name: String

    @Parent(key: BattleTech.AmmoAlias.V20240327.ammo)
    var ammo: BattleTech.Ammo

    init() {}

    init(id: UUID? = nil, name: String) {
      self.id = id
      self.name = name
    }
  }
}
