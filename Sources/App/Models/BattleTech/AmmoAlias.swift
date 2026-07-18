/// Defines the ``BattleTech/AmmoAlias`` Fluent model: an alternate name for an ammo record,
/// used so CSV imports can match ammo entries that MegaMek's data files refer to under
/// different names across revisions.
import Fluent
import Vapor

extension BattleTech {
    /// Fluent model backing the `ammo_aliases` table. Each row is one alternate name that
    /// points back to a single ``BattleTech/Ammo`` record.
    final class AmmoAlias: Model, Content, @unchecked Sendable {
        static let schema = BattleTech.AmmoAlias.V20240327.schemaName
        public static let space: String? = BattleTech.AmmoAlias.V20240327.spaceName

        @ID(key: .id)
        var id: UUID?

        @Field(key: BattleTech.AmmoAlias.V20240327.name)
        var name: String

        // `@Parent` declares the required foreign key back to the ammo record this alias
        // refers to.
        @Parent(key: BattleTech.AmmoAlias.V20240327.ammo)
        var ammo: BattleTech.Ammo

        /// Creates an empty instance for Fluent to populate when reading from the database.
        init() {}

        /// Creates a new alias with the given name, not yet linked to an ammo record.
        ///
        /// - Parameters:
        ///   - id: Optional primary key; leave `nil` for a new, unsaved record.
        ///   - name: The alternate name to record.
        init(id: UUID? = nil, name: String) {
            self.id = id
            self.name = name
        }
    }
}
