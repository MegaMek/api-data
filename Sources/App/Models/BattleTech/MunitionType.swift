/// Defines the ``BattleTech/MunitionType`` Fluent model: the category of munition an ammo
/// entry loads (e.g. Standard, Inferno, Cluster, Armor-Piercing), shared by every ``BattleTech/Ammo``
/// record of that kind.
import Fluent
import Vapor

extension BattleTech {
    /// Fluent model backing the `munition_types` table. Each row is one distinct munition
    /// type name, referenced by any number of ``BattleTech/Ammo`` records.
    final class MunitionType: Model, Content, @unchecked Sendable {
        static let schema = BattleTech.MunitionType.V20240327.schemaName
        public static let space: String? = BattleTech.MunitionType.V20240327.spaceName

        @ID(key: .id)
        var id: UUID?

        @Field(key: BattleTech.MunitionType.V20240327.name)
        var name: String

        // `@Children` is the inverse of `Ammo`'s `@Parent` relationship: every ammo record
        // that uses this munition type.
        @Children(for: \.$munitionType)
        var ammo: [BattleTech.Ammo]

        /// Creates an empty instance for Fluent to populate when reading from the database.
        init() {}

        /// Creates a new munition type with the given name.
        ///
        /// - Parameters:
        ///   - id: Optional primary key; leave `nil` for a new, unsaved record.
        ///   - name: The munition type name (e.g. "Standard", "Inferno").
        init(id: UUID? = nil, name: String) {
            self.id = id
            self.name = name
        }
    }
}
