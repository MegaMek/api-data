import Fluent
import Vapor

extension BattleTech {
    final class MunitionType: Model, Content, @unchecked Sendable {
        static let schema = BattleTech.MunitionType.V20240327.schemaName
        public static let space: String? = BattleTech.MunitionType.V20240327.spaceName

        @ID(key: .id)
        var id: UUID?

        @Field(key: BattleTech.MunitionType.V20240327.name)
        var name: String

        @Children(for: \.$munitionType)
        var ammo: [BattleTech.Ammo]

        init() {}

        init(id: UUID? = nil, name: String) {
            self.id = id
            self.name = name
        }
    }
}
