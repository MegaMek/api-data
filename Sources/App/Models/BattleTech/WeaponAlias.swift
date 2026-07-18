/// Defines the ``BattleTech/WeaponAlias`` Fluent model: an alternate name for a weapon
/// record, used so CSV imports can match weapon entries that MegaMek's data files refer to
/// under different names across revisions.
import Fluent
import Vapor

extension BattleTech {
    /// Fluent model backing the `weapon_aliases` table. Each row is one alternate name that
    /// points back to a single ``BattleTech/Weapon`` record.
    final class WeaponAlias: Model, Content, @unchecked Sendable {
        static let schema = BattleTech.WeaponAlias.V20240323.schemaName
        public static let space: String? = BattleTech.WeaponAlias.V20240323.spaceName

        @ID(key: .id)
        var id: UUID?

        @Field(key: BattleTech.WeaponAlias.V20240323.name)
        var name: String

        // `@Parent` declares the required foreign key back to the weapon record this alias
        // refers to.
        @Parent(key: BattleTech.WeaponAlias.V20240323.weapon)
        var weapon: BattleTech.Weapon

        /// Creates an empty instance for Fluent to populate when reading from the database.
        init() {}

        /// Creates a new alias with the given name, not yet linked to a weapon record.
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
