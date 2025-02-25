import Fluent
import Vapor

extension BattleTech {
    final class WeaponAlias: Model, Content, @unchecked Sendable {
        static let schema = BattleTech.WeaponAlias.V20240323.schemaName
        public static let space: String? = BattleTech.WeaponAlias.V20240323.spaceName

        @ID(key: .id)
        var id: UUID?

        @Field(key: BattleTech.WeaponAlias.V20240323.name)
        var name: String

        @Parent(key: BattleTech.WeaponAlias.V20240323.weapon)
        var weapon: BattleTech.Weapon

        init() {}

        init(id: UUID? = nil, name: String) {
            self.id = id
            self.name = name
        }
    }
}
