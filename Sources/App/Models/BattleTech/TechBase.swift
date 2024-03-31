import Fluent
import Vapor

extension BattleTech {
    final class TechBase: Model, Content {
        static let schema = BattleTech.TechBase.V20240316.schemaName
        public static let space: String? = BattleTech.TechBase.V20240316.spaceName

        @ID(key: .id)
        var id: UUID?

        @Field(key: BattleTech.TechBase.V20240316.name)
        var name: String

        @Children(for: \.$techBase)
        var ammo: [BattleTech.Ammo]

        @Children(for: \.$techBase)
        var equipment: [BattleTech.Equipment]

        @Children(for: \.$techBase)
        var weapons: [BattleTech.Weapon]

        init() { }

        init(id: UUID? = nil, name: String) {
            self.id = id
            self.name = name
        }
    }
}
