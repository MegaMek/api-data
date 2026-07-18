/// Fluent model backing the `eras` table.
///
/// A named historical period on the BattleTech timeline (e.g. Star League,
/// Succession Wars, Clan Invasion) used throughout the API to tag when
/// equipment, factions, and rules were introduced or in use.
import Fluent
import Vapor

// Extends the shared BattleTech namespace with the Era model.
extension BattleTech {
    /// One BattleTech era.
    ///
    /// A start/end year range identified by a short `code` and human-readable
    /// `name`, plus display assets (`flag`, `icon`) and the id it maps to in
    /// MegaMek's Master Unit List (MUL).
    final class Era: Model, Content, @unchecked Sendable {
        static let schema = BattleTech.Era.V20240212.schemaName
        public static let space: String? = BattleTech.Era.V20240212.spaceName

        @ID(key: .id)
        var id: UUID?

        // @Field marks a required (non-null) column; @OptionalField (below) marks a
        // nullable one. Both take the versioned column-key constants (e.g.
        // `V20240212.code`) defined in the migration files rather than raw strings.
        @Field(key: BattleTech.Era.V20240212.code)
        var code: String

        @Field(key: BattleTech.Era.V20240212.name)
        var name: String

        // startYear was added in a later migration (V20240409), so it's optional to
        // remain compatible with rows created before that column existed.
        @OptionalField(key: BattleTech.Era.V20240409.startYear)
        var startYear: Int?

        @Field(key: BattleTech.Era.V20240212.endYear)
        var endYear: Int

        // Display assets used by API consumers to render the era (flag image key,
        // optional icon).
        @Field(key: BattleTech.Era.V20240212.flag)
        var flag: String

        @OptionalField(key: BattleTech.Era.V20240212.icon)
        var icon: String?

        // External identifier linking this row to its corresponding entry in
        // MegaMek's Master Unit List (MUL).
        @Field(key: BattleTech.Era.V20240212.mulId)
        var mulId: Int

        // Publication/audit timestamps. `publishedAt` gates visibility (defaults to
        // 60 days in the past, see init below); `@Timestamp` has Fluent set
        // createdAt/updatedAt automatically on save/update.
        @Field(key: BattleTech.Era.V20240212.publishedAt)
        var publishedAt: Date?

        @Timestamp(key: BattleTech.Era.V20240212.createdAt, on: .create)
        var createdAt: Date?

        @Timestamp(key: BattleTech.Era.V20240212.updatedAt, on: .update)
        var updatedAt: Date?

        /// Empty initializer required by Fluent to hydrate model instances fetched
        /// from the database.
        init() {}

        /// Creates a new Era, defaulting `publishedAt` to 60 days ago so it is
        /// immediately visible through any "published" visibility filter.
        ///
        /// - Parameters:
        ///   - id: Optional database identifier; `nil` for a not-yet-persisted era.
        ///   - code: Short machine-readable code for the era.
        ///   - name: Human-readable display name.
        ///   - startYear: First year the era covers, or `-1` if unknown.
        ///   - endYear: Last year the era covers, or `-1` if unknown.
        ///   - flag: Key identifying the flag image asset for this era.
        ///   - icon: Optional key identifying an icon asset for this era.
        ///   - mulId: Identifier of the matching entry in MegaMek's Master Unit
        ///     List (MUL), or `-1` if unmapped.
        ///   - publishedAt: When the era becomes visible via the public API;
        ///     defaults to 60 days before now.
        init(
            id: UUID? = nil,
            code: String,
            name: String,
            startYear: Int = -1,
            endYear: Int = -1,
            flag: String,
            icon: String? = nil,
            mulId: Int = -1,
            publishedAt: Date? = Calendar.current.date(byAdding: .day, value: -60, to: Date())
        ) {
            self.id = id
            self.code = code
            self.name = name
            self.startYear = startYear
            self.endYear = endYear
            self.flag = flag
            self.icon = icon
            self.mulId = mulId
            self.publishedAt = publishedAt
        }
    }
}
