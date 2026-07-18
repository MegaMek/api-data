/// Fluent model backing the `factions` table.
///
/// A BattleTech political/military power (e.g. Federated Suns, Draconis
/// Combine, a Clan) that fields units and controls territory. Factions can
/// have sub-factions (e.g. a Clan's constituent touman or a house's periphery
/// states), modeled below as a self-referencing many-to-many relationship.
import Fluent
import Vapor

// Extends the shared BattleTech namespace with the Faction model.
extension BattleTech {
    /// One BattleTech faction.
    ///
    /// Tracks whether it is a Clan power, a minor/periphery power, the Battle
    /// Value equipment rating levels it uses, its display names over time
    /// (``BattleTech/FactionName``), and its sub-faction/parent-faction
    /// relationships.
    final class Faction: Model, Content, @unchecked Sendable {
        static let schema = BattleTech.Faction.V20240316.schemaName
        public static let space: String? = BattleTech.Faction.V20240316.spaceName

        @ID(key: .id)
        var id: UUID?

        @Field(key: BattleTech.Faction.V20240316.factionKey)
        var factionKey: String

        // Classification flags: is this a minor faction, a Clan (as opposed to
        // Inner Sphere), and/or a periphery (frontier, non-Great-House) power.
        @Field(key: BattleTech.Faction.V20240316.minor)
        var minor: Bool

        @Field(key: BattleTech.Faction.V20240316.clan)
        var clan: Bool

        @Field(key: BattleTech.Faction.V20240316.periphery)
        var periphery: Bool

        @Field(key: BattleTech.Faction.V20240316.ratingLevels)
        var ratingLevels: String

        // @Children declares the "one" side of a one-to-many relationship: each
        // BattleTech.FactionName row points back at this faction via its own
        // @Parent.
        @Children(for: \.$faction)
        var names: [BattleTech.FactionName]

        // @Siblings declares a many-to-many relationship backed by a pivot (join)
        // table — here, BattleTech.FactionSubfactionPivot — instead of a foreign
        // key on either side. Because a Faction can itself be another Faction's
        // sub-faction, this relation is self-referencing: `subfactions` walks the
        // pivot in one direction, `parents` walks it in the other.
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

        /// Empty initializer required by Fluent to hydrate model instances fetched
        /// from the database.
        init() {}

        /// Creates a new Faction, defaulting `publishedAt` to 60 days ago so it is
        /// immediately visible through any "published" visibility filter.
        ///
        /// - Parameters:
        ///   - id: Optional database identifier; `nil` for a not-yet-persisted
        ///     faction.
        ///   - factionKey: Unique machine-readable key for this faction.
        ///   - minor: Whether this is a minor faction rather than a major power.
        ///   - clan: Whether this is a Clan faction (as opposed to Inner Sphere).
        ///   - periphery: Whether this is a periphery (frontier) power.
        ///   - ratingLevels: The Battle Value equipment rating levels this
        ///     faction uses.
        ///   - publishedAt: When the faction becomes visible via the public
        ///     API; defaults to 60 days before now.
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
