import Fluent
import Vapor

extension BattleTech {
    final class EquipmentAlias: Model, Content {
        static let schema = BattleTech.EquipmentAlias.V20240330.schemaName
        public static let space: String? = BattleTech.EquipmentAlias.V20240330.spaceName

        @ID(key: .id)
        var id: UUID?

        @Field(key: BattleTech.EquipmentAlias.V20240330.name)
        var name: String

        @Parent(key: BattleTech.EquipmentAlias.V20240330.equipment)
        var equipment: BattleTech.Equipment

        init() { }

        init(id: UUID? = nil, name: String) {
            self.id = id
            self.name = name
        }
    }
}
