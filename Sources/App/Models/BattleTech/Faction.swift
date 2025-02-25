import Fluent
import Vapor

extension BattleTech {
    final class Faction: Model, Content, @unchecked Sendable {
        static let schema = BattleTech.Faction.V20240316.schemaName
        public static let space: String? = BattleTech.Faction.V20240316.spaceName

        @ID(key: .id)
        var id: UUID?

        @Field(key: BattleTech.Faction.V20240316.factionKey)
        var factionKey: String

        @Field(key: BattleTech.Faction.V20240316.minor)
        var minor: Bool

        @Field(key: BattleTech.Faction.V20240316.clan)
        var clan: Bool

        @Field(key: BattleTech.Faction.V20240316.periphery)
        var periphery: Bool

        @Field(key: BattleTech.Faction.V20240316.ratingLevels)
        var ratingLevels: String

        @Children(for: \.$faction)
        var names: [BattleTech.FactionName]

        @Siblings(
            through: BattleTech.FactionSubfactionPivot.self,
            from: \.$faction,
            to: \.$subfaction
        )
        var subfactions: [BattleTech.Faction]

        @Siblings(
            through: BattleTech.FactionSubfactionPivot.self,
            from: \.$subfaction,
            to: \.$faction
        )
        var parents: [BattleTech.Faction]

        @Field(key: BattleTech.Faction.V20240316.publishedAt)
        var publishedAt: Date?

        @Timestamp(key: BattleTech.Faction.V20240316.createdAt, on: .create)
        var createdAt: Date?

        @Timestamp(key: BattleTech.Faction.V20240316.updatedAt, on: .update)
        var updatedAt: Date?

        init() {}

        init(
            id: UUID? = nil,
            factionKey: String,
            minor: Bool = false,
            clan: Bool = false,
            periphery: Bool = false,
            ratingLevels: String,
            publishedAt: Date? = Calendar.current.date(byAdding: .day, value: -60, to: Date())
        ) {
            self.id = id
            self.factionKey = factionKey
            self.minor = minor
            self.clan = clan
            self.periphery = periphery
            self.ratingLevels = ratingLevels
            self.publishedAt = publishedAt
        }
    }
}
