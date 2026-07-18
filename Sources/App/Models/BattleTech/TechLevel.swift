/// Fluent model backing the `tech_levels` table.
///
/// A tech level classifies how advanced/restricted a piece of equipment is
/// for tabletop play (e.g. "Introductory", "Standard", "Advanced",
/// "Experimental"), independent of its ``BattleTech/TechBase`` (Inner Sphere
/// vs. Clan). Every ``BattleTech/Ammo``, `Equipment`, and ``BattleTech/Weapon``
/// row references one tech level.
import Fluent
import Vapor

// Extends the shared BattleTech namespace with the TechLevel model.
extension BattleTech {
    /// One tech level (e.g. Standard, Advanced) and the equipment items
    /// classified under it.
    final class TechLevel: Model, Content, @unchecked Sendable {
        static let schema = BattleTech.TechLevel.V20240316.schemaName
        public static let space: String? = BattleTech.TechLevel.V20240316.spaceName

        @ID(key: .id)
        var id: UUID?

        @Field(key: BattleTech.TechLevel.V20240316.name)
        var name: String

        // @Children declares the "one" side of a one-to-many relationship:
        // each item row points back at this tech level (its "static", i.e.
        // rules-defined, tech level) via its own @Parent.
        @Children(for: \.$techLevelStatic)
        var ammo: [BattleTech.Ammo]

        @Children(for: \.$techLevelStatic)
        var equipment: [BattleTech.Equipment]

        @Children(for: \.$techLevelStatic)
        var weapons: [BattleTech.Weapon]

        /// Empty initializer required by Fluent to hydrate model instances
        /// fetched from the database.
        init() {}

        /// Creates a new TechLevel with the given name.
        ///
        /// - Parameters:
        ///   - id: Optional database identifier; `nil` for a not-yet-persisted
        ///     tech level.
        ///   - name: The tech level's unique display name (e.g. "Standard",
        ///     "Advanced").
        init(id: UUID? = nil, name: String) {
            self.id = id
            self.name = name
        }
    }
}
