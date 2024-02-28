import Fluent
import Vapor

extension BattleTech {
    final class Era: Model, Content {
        static let schema = BattleTech.Era.V20240212.schemaName
        public static let space: String? = BattleTech.Era.V20240212.spaceName

        @ID(key: .id)
        var id: UUID?

        @Field(key: BattleTech.Era.V20240212.code)
        var code: String

        @Field(key: BattleTech.Era.V20240212.name)
        var name: String

        @Field(key: BattleTech.Era.V20240212.endYear)
        var endYear: Int

        @Field(key: BattleTech.Era.V20240212.flag)
        var flag: String

        @OptionalField(key: BattleTech.Era.V20240212.icon)
        var icon: String?

        @Field(key: BattleTech.Era.V20240212.mulId)
        var mulId: Int

        @Field(key: BattleTech.Era.V20240212.publishedAt)
        var publishedAt: Date?

        @Timestamp(key: BattleTech.Era.V20240212.createdAt, on: .create)
        var createdAt: Date?

        @Timestamp(key: BattleTech.Era.V20240212.updatedAt, on: .update)
        var updatedAt: Date?

        @Timestamp(key: BattleTech.Era.V20240212.deletedAt, on: .delete)
        var deletedAt: Date?

        init() { }

        init(
            id: UUID? = nil,
            code: String,
            name: String,
            endYear: Int = -1,
            flag: String,
            icon: String? = nil,
            mulId: Int = -1,
            publishedAt: Date? = Calendar.current.date(byAdding: .day, value: -60, to: Date())
        ) {
            self.id = id
            self.code = code
            self.name = name
            self.endYear = endYear
            self.flag = flag
            self.icon = icon
            self.mulId = mulId
            self.publishedAt = publishedAt
        }
    }
}
