/// Fluent model backing the `faction_names` table.
///
/// A historical display name for a faction over a given year range. Factions
/// are renamed or rebranded over the course of BattleTech's timeline (e.g.
/// after a merger or civil war), so a ``BattleTech/Faction`` can own several
/// of these rather than a single fixed `name` field.
import Fluent
import Vapor

// Extends the shared BattleTech namespace with the FactionName model.
extension BattleTech {
    /// One name a faction was known by during a particular era.
    ///
    /// Stores the optional start/end years it applied and an optional
    /// display image.
    final class FactionName: Model, Content, @unchecked Sendable {
        static let schema = BattleTech.FactionName.V20240316.schemaName
        public static let space: String? = BattleTech.FactionName.V20240316.spaceName

        @ID(key: .id)
        var id: UUID?

        // The name text and the year range it was in use; both bounds are
        // optional since some names have no recorded start/end.
        @Field(key: BattleTech.FactionName.V20240316.name)
        var name: String

        @Field(key: BattleTech.FactionName.V20240316.startYear)
        var startYear: Int?

        @OptionalField(key: BattleTech.FactionName.V20240316.endYear)
        var endYear: Int?

        // @Parent declares the "many" side of a one-to-many relationship: this
        // stores the owning BattleTech.Faction's id as a foreign key, mirroring
        // the @Children collection on BattleTech.Faction.names.
        @Parent(key: BattleTech.FactionName.V20240316.faction)
        var faction: BattleTech.Faction

        @OptionalField(key: BattleTech.FactionName.V20240415.image)
        var image: String?

        /// Empty initializer required by Fluent to hydrate model instances fetched
        /// from the database.
        init() {}

        /// Creates a new FactionName. The `faction` relationship is set
        /// separately (e.g. via `$faction.id`) after construction.
        ///
        /// - Parameters:
        ///   - id: Optional database identifier; `nil` for a not-yet-persisted
        ///     name.
        ///   - name: The display name text.
        ///   - startYear: First year this name was in use, if known.
        ///   - endYear: Last year this name was in use, if known.
        ///   - image: Optional key identifying a display image asset.
        init(
            id: UUID? = nil,
            name: String,
            startYear: Int? = nil,
            endYear: Int? = nil,
            image: String? = nil
        ) {
            self.id = id
            self.name = name
            self.startYear = startYear
            self.image = image
            self.endYear = endYear
        }
    }
}
