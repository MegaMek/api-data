/// Defines the ``BattleTech/Ammo`` Fluent model, which represents a single row in the `ammo`
/// database table: one ammunition type (e.g. "Standard LRM Ammo") along with its tech-base,
/// tonnage/cost/critical-slot stats, and ballistic properties (damage per shot, rack size, etc).
/// This is the source-of-truth record served by the public read-only BattleTech data API.
import Fluent
import Vapor

extension BattleTech {
    /// Fluent model backing the `ammo` table.
    ///
    /// Each row is one ammunition entry sourced from MegaMek's data files, linked to a
    /// ``BattleTech/TechBase``, a static ``BattleTech/TechLevel``, a ``BattleTech/MunitionType``
    /// (e.g. Standard, Inferno, Cluster), and any applicable ``BattleTech/Rule``s and
    /// ``BattleTech/AmmoAlias`` name aliases.
    final class Ammo: Model, Content, @unchecked Sendable {
        static let schema = BattleTech.Ammo.V20240327.schemaName
        public static let space: String? = BattleTech.Ammo.V20240327.spaceName

        @ID(key: .id)
        var id: UUID?

        @Field(key: BattleTech.Ammo.V20240327.name)
        var name: String

        // `@Parent` declares a required foreign-key relationship: this ammo belongs to exactly
        // one tech base record (Inner Sphere, Clan, etc).
        @Parent(key: BattleTech.Ammo.V20240327.techBase)
        var techBase: BattleTech.TechBase

        // `@Siblings` exposes a many-to-many relationship through the `AmmoRulePivot` join
        // table: the optional/errata rulebook rules that apply to this ammo.
        @Siblings(through: BattleTech.AmmoRulePivot.self, from: \.$ammo, to: \.$rule)
        var rules: [BattleTech.Rule]

        // Tech rating (A-F scale) describing how advanced/rare the technology is.
        @Field(key: BattleTech.Ammo.V20240327.techRating)
        var techRating: String

        @Parent(key: BattleTech.Ammo.V20240327.techLevelStatic)
        var techLevelStatic: BattleTech.TechLevel

        // In-universe timeline dates (as free-form strings) marking this ammo's lifecycle:
        // when it was first designed, entered production, became common, went extinct, etc.
        // `@OptionalField` means the column may be null since not every entry has every date.
        @OptionalField(key: BattleTech.Ammo.V20240327.introductionDate)
        var introductionDate: String?

        @OptionalField(key: BattleTech.Ammo.V20240327.prototypeDate)
        var prototypeDate: String?

        @OptionalField(key: BattleTech.Ammo.V20240327.productionDate)
        var productionDate: String?

        @OptionalField(key: BattleTech.Ammo.V20240327.commonDate)
        var commonDate: String?

        @OptionalField(key: BattleTech.Ammo.V20240327.extinctionDate)
        var extinctionDate: String?

        @OptionalField(key: BattleTech.Ammo.V20240327.reIntroductionDate)
        var reIntroductionDate: String?

        // Core stat block: weight in tons, equipment slots consumed, C-bill cost, and
        // Battle Value (the point-cost system used to balance forces).
        @Field(key: BattleTech.Ammo.V20240327.tonnage)
        var tonnage: Double

        @Field(key: BattleTech.Ammo.V20240327.criticalSlots)
        var criticalSlots: Int

        @Field(key: BattleTech.Ammo.V20240327.cost)
        var cost: Double

        @Field(key: BattleTech.Ammo.V20240327.battleValue)
        var battleValue: Double

        @OptionalField(key: BattleTech.Ammo.V20240327.rulesReference)
        var rulesReference: String?

        // Whether this ammo counts as flak (anti-aircraft) fire for hit resolution purposes.
        @Field(key: BattleTech.Ammo.V20240327.countAsFlak)
        var countAsFlak: Bool

        @Parent(key: BattleTech.Ammo.V20240327.munitionType)
        var munitionType: BattleTech.MunitionType

        // Ballistic profile: damage dealt by a single shot, the weapon rack size it's sized
        // for, how many shots one ton/unit of this ammo provides, and the ammo-per-ton ratio.
        @Field(key: BattleTech.Ammo.V20240327.damagePerShot)
        var damagePerShot: Int

        @Field(key: BattleTech.Ammo.V20240327.rackSize)
        var rackSize: Int

        @Field(key: BattleTech.Ammo.V20240327.shots)
        var shots: Int

        @Field(key: BattleTech.Ammo.V20240327.ammoRatio)
        var ammoRatio: Double

        // Capital-scale (used by large spacecraft weapons) and per-shot weight in kilograms,
        // plus whether this ammo is usable by aerospace units.
        @Field(key: BattleTech.Ammo.V20240327.isCapital)
        var isCapital: Bool

        @Field(key: BattleTech.Ammo.V20240327.kilogramPerShot)
        var kilogramPerShot: Double

        @Field(key: BattleTech.Ammo.V20240327.aeroUse)
        var aeroUse: Bool

        // `@Children` is the inverse of `@Parent`: all the alternate names this ammo is known
        // by, used to match legacy/varied naming when importing CSV data.
        @Children(for: \.$ammo)
        var aliases: [BattleTech.AmmoAlias]

        @Field(key: BattleTech.Ammo.V20240327.publishedAt)
        var publishedAt: Date?

        // `@Timestamp` fields are managed automatically by Fluent: set on insert / on update.
        @Timestamp(key: BattleTech.Ammo.V20240327.createdAt, on: .create)
        var createdAt: Date?

        @Timestamp(key: BattleTech.Ammo.V20240327.updatedAt, on: .update)
        var updatedAt: Date?

        /// Creates an empty instance for Fluent to populate when reading from the database.
        ///
        /// Defaults `publishedAt` to 60 days ago so newly-created records are already public.
        init() {
            self.publishedAt = Calendar.current.date(byAdding: .day, value: -60, to: Date())
        }

        /// Full member-wise initializer used when constructing an ammo record directly
        /// (e.g. in tests or data importers) with all of its stats and related records.
        ///
        /// - Parameters:
        ///   - id: Optional primary key; leave `nil` for a new, unsaved record.
        ///   - name: Display name of the ammunition.
        ///   - techBase: The ``BattleTech/TechBase`` (e.g. Inner Sphere, Clan) this ammo belongs to.
        ///   - techRating: Tech rating (A-F scale) for how advanced/rare the tech is.
        ///   - techLevelStatic: The ``BattleTech/TechLevel`` this ammo is classified under.
        ///   - introductionDate: In-universe year this ammo was first introduced.
        ///   - prototypeDate: In-universe year this ammo existed as a prototype.
        ///   - productionDate: In-universe year mass production began.
        ///   - commonDate: In-universe year this ammo became commonly available.
        ///   - extinctionDate: In-universe year this ammo went extinct, if applicable.
        ///   - reIntroductionDate: In-universe year this ammo was reintroduced, if applicable.
        ///   - tonnage: Weight in tons.
        ///   - criticalSlots: Number of critical/equipment slots consumed.
        ///   - cost: Cost in C-bills.
        ///   - battleValue: Battle Value point cost used for force balancing.
        ///   - rulesReference: Rulebook page/section this ammo is defined in.
        ///   - countAsFlak: Whether this ammo counts as flak (anti-aircraft) fire.
        ///   - munitionType: The ``BattleTech/MunitionType`` (e.g. Standard, Inferno, Cluster).
        ///   - damagePerShot: Damage dealt by a single shot.
        ///   - rackSize: Weapon rack size this ammo is sized for.
        ///   - shots: Number of shots provided per ton/unit of this ammo.
        ///   - ammoRatio: Ammo-per-ton ratio.
        ///   - isCapital: Whether this is capital-scale ammo used by large spacecraft weapons.
        ///   - kilogramPerShot: Per-shot weight in kilograms.
        ///   - aeroUse: Whether this ammo is usable by aerospace units.
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
            countAsFlak: Bool = false,
            munitionType: BattleTech.MunitionType,
            damagePerShot: Int = 0,
            rackSize: Int = 0,
            shots: Int = 0,
            ammoRatio: Double = 0.0,
            isCapital: Bool = false,
            kilogramPerShot: Double = 0.0,
            aeroUse: Bool = false,
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
            self.countAsFlak = countAsFlak
            self.damagePerShot = damagePerShot
            self.rackSize = rackSize
            self.shots = shots
            self.ammoRatio = ammoRatio
            self.isCapital = isCapital
            self.kilogramPerShot = kilogramPerShot
            self.aeroUse = aeroUse

            self.publishedAt = publishedAt

            self.$techBase.id = techBase.id!
            self.$techLevelStatic.id = techLevelStatic.id!
            self.$munitionType.id = munitionType.id!
        }
    }
}
