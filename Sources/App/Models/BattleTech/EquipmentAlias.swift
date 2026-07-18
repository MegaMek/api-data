/// Defines the ``BattleTech/EquipmentAlias`` Fluent model: an alternate name for an equipment
/// record, used so CSV imports can match equipment entries that MegaMek's data files refer to
/// under different names across revisions.
import Fluent
import Vapor

extension BattleTech {
    /// Fluent model backing the `equipment_aliases` table. Each row is one alternate name
    /// that points back to a single ``BattleTech/Equipment`` record.
    final class EquipmentAlias: Model, Content, @unchecked Sendable {
        static let schema = BattleTech.EquipmentAlias.V20240330.schemaName
        public static let space: String? = BattleTech.EquipmentAlias.V20240330.spaceName

        @ID(key: .id)
        var id: UUID?

        @Field(key: BattleTech.EquipmentAlias.V20240330.name)
        var name: String

        // `@Parent` declares the required foreign key back to the equipment record this
        // alias refers to.
        @Parent(key: BattleTech.EquipmentAlias.V20240330.equipment)
        var equipment: BattleTech.Equipment

        /// Creates an empty instance for Fluent to populate when reading from the database.
        init() {}

        /// Creates a new alias with the given name, not yet linked to an equipment record.
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
