/// Fluent model backing the `tech_bases` table.
///
/// A tech base identifies which technological lineage a piece of equipment
/// comes from — typically "Inner Sphere" or "Clan" (the two major BattleTech
/// tech traditions), though mixed-tech variants also exist. Every
/// ``BattleTech/Ammo``, `Equipment`, and ``BattleTech/Weapon`` row references
/// one tech base.
import Fluent
import Vapor

// Extends the shared BattleTech namespace with the TechBase model.
extension BattleTech {
    /// One tech base (e.g. Inner Sphere or Clan) and the equipment items that
    /// belong to it.
    final class TechBase: Model, Content, @unchecked Sendable {
        static let schema = BattleTech.TechBase.V20240316.schemaName
        public static let space: String? = BattleTech.TechBase.V20240316.spaceName

        @ID(key: .id)
        var id: UUID?

        @Field(key: BattleTech.TechBase.V20240316.name)
        var name: String

        // @Children declares the "one" side of a one-to-many relationship:
        // each item row points back at this tech base via its own @Parent.
        @Children(for: \.$techBase)
        var ammo: [BattleTech.Ammo]

        @Children(for: \.$techBase)
        var equipment: [BattleTech.Equipment]

        @Children(for: \.$techBase)
        var weapons: [BattleTech.Weapon]

        /// Empty initializer required by Fluent to hydrate model instances
        /// fetched from the database.
        init() {}

        /// Creates a new TechBase with the given name.
        ///
        /// - Parameters:
        ///   - id: Optional database identifier; `nil` for a not-yet-persisted
        ///     tech base.
        ///   - name: The tech base's unique display name (e.g. "Inner Sphere",
        ///     "Clan").
        init(id: UUID? = nil, name: String) {
            self.id = id
            self.name = name
        }
    }
}
