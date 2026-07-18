/// Defines the ``BattleTech/Equipment`` Fluent model, which represents a single row in the
/// `equipment` table: general-purpose gear (e.g. heat sinks, jump jets, targeting computers)
/// as opposed to weapons or ammo, along with its tech-base and stat block. Served by the
/// public read-only BattleTech data API.
import Fluent
import Vapor

extension BattleTech {
    /// Fluent model backing the `equipment` table.
    ///
    /// Each row is one piece of non-weapon, non-ammo equipment sourced from MegaMek's data
    /// files, linked to a ``BattleTech/TechBase``, a static ``BattleTech/TechLevel``, and any
    /// applicable ``BattleTech/Rule``s and ``BattleTech/EquipmentAlias`` name aliases.
    final class Equipment: Model, Content, @unchecked Sendable {
        static let schema = BattleTech.Equipment.V20240330.schemaName
        public static let space: String? = BattleTech.Equipment.V20240330.spaceName

        @ID(key: .id)
        var id: UUID?

        @Field(key: BattleTech.Equipment.V20240330.name)
        var name: String

        // `@Parent` declares a required foreign-key relationship: this equipment belongs to
        // exactly one tech base record (Inner Sphere, Clan, etc).
        @Parent(key: BattleTech.Equipment.V20240330.techBase)
        var techBase: BattleTech.TechBase

        // `@Siblings` exposes a many-to-many relationship through the `EquipmentRulePivot`
        // join table: the optional/errata rulebook rules that apply to this equipment.
        @Siblings(through: BattleTech.EquipmentRulePivot.self, from: \.$equipment, to: \.$rule)
        var rules: [BattleTech.Rule]

        // Tech rating (A-F scale) describing how advanced/rare the technology is.
        @Field(key: BattleTech.Equipment.V20240330.techRating)
        var techRating: String

        @Parent(key: BattleTech.Equipment.V20240330.techLevelStatic)
        var techLevelStatic: BattleTech.TechLevel

        // In-universe timeline dates (as free-form strings) marking this equipment's
        // lifecycle: when it was first designed, entered production, became common, went
        // extinct, etc. `@OptionalField` means the column may be null since not every entry
        // has every date.
        @OptionalField(key: BattleTech.Equipment.V20240330.introductionDate)
        var introductionDate: String?

        @OptionalField(key: BattleTech.Equipment.V20240330.prototypeDate)
        var prototypeDate: String?

        @OptionalField(key: BattleTech.Equipment.V20240330.productionDate)
        var productionDate: String?

        @OptionalField(key: BattleTech.Equipment.V20240330.commonDate)
        var commonDate: String?

        @OptionalField(key: BattleTech.Equipment.V20240330.extinctionDate)
        var extinctionDate: String?

        @OptionalField(key: BattleTech.Equipment.V20240330.reIntroductionDate)
        var reIntroductionDate: String?

        // Core stat block: weight in tons, equipment slots consumed, C-bill cost, and
        // Battle Value (the point-cost system used to balance forces).
        @Field(key: BattleTech.Equipment.V20240330.tonnage)
        var tonnage: Double

        @Field(key: BattleTech.Equipment.V20240330.criticalSlots)
        var criticalSlots: Int

        @Field(key: BattleTech.Equipment.V20240330.cost)
        var cost: Double

        @Field(key: BattleTech.Equipment.V20240330.battleValue)
        var battleValue: Double

        @OptionalField(key: BattleTech.Equipment.V20240330.rulesReference)
        var rulesReference: String?

        // `@Children` is the inverse of `@Parent`: all the alternate names this equipment is
        // known by, used to match legacy/varied naming when importing CSV data.
        @Children(for: \.$equipment)
        var aliases: [BattleTech.EquipmentAlias]

        @Field(key: BattleTech.Equipment.V20240330.publishedAt)
        var publishedAt: Date?

        // `@Timestamp` fields are managed automatically by Fluent: set on insert / on update.
        @Timestamp(key: BattleTech.Equipment.V20240330.createdAt, on: .create)
        var createdAt: Date?

        @Timestamp(key: BattleTech.Equipment.V20240330.updatedAt, on: .update)
        var updatedAt: Date?

        /// Creates an empty instance for Fluent to populate when reading from the database.
        ///
        /// Defaults `publishedAt` to 60 days ago so newly-created records are already public.
        init() {
            self.publishedAt = Calendar.current.date(byAdding: .day, value: -60, to: Date())
        }

        /// Full member-wise initializer used when constructing an equipment record directly
        /// (e.g. in tests or data importers) with all of its stats and related records.
        ///
        /// - Parameters:
        ///   - id: Optional primary key; leave `nil` for a new, unsaved record.
        ///   - name: Display name of the equipment.
        ///   - techBase: The ``BattleTech/TechBase`` (e.g. Inner Sphere, Clan) this equipment belongs to.
        ///   - techRating: Tech rating (A-F scale) for how advanced/rare the tech is.
        ///   - techLevelStatic: The ``BattleTech/TechLevel`` this equipment is classified under.
        ///   - introductionDate: In-universe year this equipment was first introduced.
        ///   - prototypeDate: In-universe year this equipment existed as a prototype.
        ///   - productionDate: In-universe year mass production began.
        ///   - commonDate: In-universe year this equipment became commonly available.
        ///   - extinctionDate: In-universe year this equipment went extinct, if applicable.
        ///   - reIntroductionDate: In-universe year this equipment was reintroduced, if applicable.
        ///   - tonnage: Weight in tons.
        ///   - criticalSlots: Number of critical/equipment slots consumed.
        ///   - cost: Cost in C-bills.
        ///   - battleValue: Battle Value point cost used for force balancing.
        ///   - rulesReference: Rulebook page/section this equipment is defined in.
        ///   - publishedAt: When this record becomes visible via the public API; defaults to 60 days ago.
        init(
            id: UUID? = nil,
            name: String,
            techBase: BattleTech.TechBase,
            techRating: String,
            techLevelStatic: BattleTech.TechLevel,
            introductionDate: String,
            prototypeDate: String,
            productionDate: String,
            commonDate: String,
            extinctionDate: String,
            reIntroductionDate: String,
            tonnage: Double = 0.0,
            criticalSlots: Int = 0,
            cost: Double = 0.0,
            battleValue: Double = 0.0,
            rulesReference: String = "",
            publishedAt: Date? = Calendar.current.date(byAdding: .day, value: -60, to: Date())
        ) {
            self.id = id
            self.name = name
            self.techRating = techRating
            self.introductionDate = introductionDate
            self.prototypeDate = productionDate
            self.productionDate = productionDate
            self.commonDate = commonDate
            self.extinctionDate = extinctionDate
            self.reIntroductionDate = reIntroductionDate
            self.tonnage = tonnage
            self.criticalSlots = criticalSlots
            self.cost = cost
            self.battleValue = battleValue
            self.rulesReference = rulesReference

            self.publishedAt = publishedAt

            self.$techBase.id = techBase.id!
            self.$techLevelStatic.id = techLevelStatic.id!
        }
    }
}
