import Fluent
import Vapor

extension BattleTech {
  final class TechLevel: Model, Content {
    static let schema = BattleTech.TechLevel.V20240316.schemaName
    public static let space: String? = BattleTech.TechLevel.V20240316.spaceName

    @ID(key: .id)
    var id: UUID?

    @Field(key: BattleTech.TechLevel.V20240316.name)
    var name: String

    @Children(for: \.$techLevelStatic)
    var ammo: [BattleTech.Ammo]

    @Children(for: \.$techLevelStatic)
    var equipment: [BattleTech.Equipment]

    @Children(for: \.$techLevelStatic)
    var weapons: [BattleTech.Weapon]

    init() {}

    init(id: UUID? = nil, name: String) {
      self.id = id
      self.name = name
    }
  }
}
