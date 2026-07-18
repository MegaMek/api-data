/// Defines the ``BattleTech/Weapon`` Fluent model, which represents a single row in the
/// `weapons` table: one weapon system (e.g. "Medium Laser", "LRM 20") along with its
/// tech-base, stat block, and per-range-bracket damage/range figures. This is the
/// source-of-truth record served by the public read-only BattleTech data API.
import Fluent
import Vapor

extension BattleTech {
    /// Fluent model backing the `weapons` table.
    ///
    /// Each row is one weapon entry sourced from MegaMek's data files, linked to a
    /// ``BattleTech/TechBase``, a static ``BattleTech/TechLevel``, and any applicable
    /// ``BattleTech/Rule``s and ``BattleTech/WeaponAlias`` name aliases.
    final class Weapon: Model, Content, @unchecked Sendable {
        static let schema = BattleTech.Weapon.V20240316.schemaName
        public static let space: String? = BattleTech.Weapon.V20240316.spaceName

        @ID(key: .id)
        var id: UUID?

        @Field(key: BattleTech.Weapon.V20240316.name)
        var name: String

        // `@Parent` declares a required foreign-key relationship: this weapon belongs to
        // exactly one tech base record (Inner Sphere, Clan, etc).
        @Parent(key: BattleTech.Weapon.V20240316.techBase)
        var techBase: BattleTech.TechBase

        // `@Siblings` exposes a many-to-many relationship through the `RuleWeaponPivot` join
        // table: the optional/errata rulebook rules that apply to this weapon.
        @Siblings(through: BattleTech.RuleWeaponPivot.self, from: \.$weapon, to: \.$rule)
        var rules: [BattleTech.Rule]

        // Tech rating (A-F scale) describing how advanced/rare the technology is.
        @Field(key: BattleTech.Weapon.V20240316.techRating)
        var techRating: String

        @Parent(key: BattleTech.Weapon.V20240316.techLevelStatic)
        var techLevelStatic: BattleTech.TechLevel

        // In-universe timeline dates (as free-form strings) marking this weapon's lifecycle:
        // when it was first designed, entered production, became common, went extinct, etc.
        // `@OptionalField` means the column may be null since not every entry has every date.
        @OptionalField(key: BattleTech.Weapon.V20240316.introductionDate)
        var introductionDate: String?

        @OptionalField(key: BattleTech.Weapon.V20240316.prototypeDate)
        var prototypeDate: String?

        @OptionalField(key: BattleTech.Weapon.V20240316.productionDate)
        var productionDate: String?

        @OptionalField(key: BattleTech.Weapon.V20240316.commonDate)
        var commonDate: String?

        @OptionalField(key: BattleTech.Weapon.V20240316.extinctionDate)
        var extinctionDate: String?

        @OptionalField(key: BattleTech.Weapon.V20240316.reIntroductionDate)
        var reIntroductionDate: String?

        // Core stat block: weight in tons, equipment slots consumed, C-bill cost, and
        // Battle Value (the point-cost system used to balance forces).
        @Field(key: BattleTech.Weapon.V20240316.tonnage)
        var tonnage: Double

        @Field(key: BattleTech.Weapon.V20240316.criticalSlots)
        var criticalSlots: Int

        @Field(key: BattleTech.Weapon.V20240316.cost)
        var cost: Double

        @Field(key: BattleTech.Weapon.V20240316.battleValue)
        var battleValue: Double

        @OptionalField(key: BattleTech.Weapon.V20240316.rulesReference)
        var rulesReference: String?

        // Range brackets, in hexes, at which this weapon can fire on land: minimal (a
        // to-hit penalty applies below this range), short, medium, long, and extreme.
        @Field(key: BattleTech.Weapon.V20240316.minimalRange)
        var minimalRange: Int

        @Field(key: BattleTech.Weapon.V20240316.shortRange)
        var shortRange: Int

        @Field(key: BattleTech.Weapon.V20240316.mediumRange)
        var mediumRange: Int

        @Field(key: BattleTech.Weapon.V20240316.longRange)
        var longRange: Int

        @Field(key: BattleTech.Weapon.V20240316.extremeRange)
        var extremeRange: Int

        // Equivalent range brackets, in hexes, when firing underwater.
        @Field(key: BattleTech.Weapon.V20240316.shortWaterRange)
        var shortWaterRange: Int

        @Field(key: BattleTech.Weapon.V20240316.mediumWaterRange)
        var mediumWaterRange: Int

        @Field(key: BattleTech.Weapon.V20240316.longWaterRange)
        var longWaterRange: Int

        @Field(key: BattleTech.Weapon.V20240316.extremeWaterRange)
        var extremeWaterRange: Int

        // Damage dealt at each range bracket, in points.
        @Field(key: BattleTech.Weapon.V20240316.minimalRangeDamage)
        var minimalRangeDamage: Int

        @Field(key: BattleTech.Weapon.V20240316.shortRangeDamage)
        var shortRangeDamage: Int

        @Field(key: BattleTech.Weapon.V20240316.mediumRangeDamage)
        var mediumRangeDamage: Int

        @Field(key: BattleTech.Weapon.V20240316.longRangeDamage)
        var longRangeDamage: Int

        @Field(key: BattleTech.Weapon.V20240316.extremeRangeDamage)
        var extremeRangeDamage: Int

        // `@Children` is the inverse of `@Parent`: all the alternate names this weapon is
        // known by, used to match legacy/varied naming when importing CSV data.
        @Children(for: \.$weapon)
        var aliases: [BattleTech.WeaponAlias]

        @Field(key: BattleTech.Weapon.V20240316.publishedAt)
        var publishedAt: Date?

        // `@Timestamp` fields are managed automatically by Fluent: set on insert / on update.
        @Timestamp(key: BattleTech.Weapon.V20240316.createdAt, on: .create)
        var createdAt: Date?

        @Timestamp(key: BattleTech.Weapon.V20240316.updatedAt, on: .update)
        var updatedAt: Date?

        /// Creates an empty instance for Fluent to populate when reading from the database.
        ///
        /// Defaults `publishedAt` to 60 days ago so newly-created records are already public.
        init() {
            self.publishedAt = Calendar.current.date(byAdding: .day, value: -60, to: Date())
        }

        /// Full member-wise initializer used when constructing a weapon record directly
        /// (e.g. in tests or data importers) with all of its stats and related records.
        ///
        /// - Parameters:
        ///   - id: Optional primary key; leave `nil` for a new, unsaved record.
        ///   - name: Display name of the weapon.
        ///   - techBase: The ``BattleTech/TechBase`` (e.g. Inner Sphere, Clan) this weapon belongs to.
        ///   - techRating: Tech rating (A-F scale) for how advanced/rare the tech is.
        ///   - techLevelStatic: The ``BattleTech/TechLevel`` this weapon is classified under.
        ///   - introductionDate: In-universe year this weapon was first introduced.
        ///   - prototypeDate: In-universe year this weapon existed as a prototype.
        ///   - productionDate: In-universe year mass production began.
        ///   - commonDate: In-universe year this weapon became commonly available.
        ///   - extinctionDate: In-universe year this weapon went extinct, if applicable.
        ///   - reIntroductionDate: In-universe year this weapon was reintroduced, if applicable.
        ///   - tonnage: Weight in tons.
        ///   - criticalSlots: Number of critical/equipment slots consumed.
        ///   - cost: Cost in C-bills.
        ///   - battleValue: Battle Value point cost used for force balancing.
        ///   - rulesReference: Rulebook page/section this weapon is defined in.
        ///   - minimalRange: Land minimal range, in hexes, below which a to-hit penalty applies.
        ///   - shortRange: Land short range bracket, in hexes.
        ///   - mediumRange: Land medium range bracket, in hexes.
        ///   - longRange: Land long range bracket, in hexes.
        ///   - extremeRange: Land extreme range bracket, in hexes.
        ///   - shortWaterRange: Underwater short range bracket, in hexes.
        ///   - mediumWaterRange: Underwater medium range bracket, in hexes.
        ///   - longWaterRange: Underwater long range bracket, in hexes.
        ///   - extremeWaterRange: Underwater extreme range bracket, in hexes.
        ///   - minimalRangeDamage: Damage dealt at minimal range.
        ///   - shortRangeDamage: Damage dealt at short range.
        ///   - mediumRangeDamage: Damage dealt at medium range.
        ///   - longRangeDamage: Damage dealt at long range.
        ///   - extremeRangeDamage: Damage dealt at extreme range.
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
            tonnage: Double,
            criticalSlots: Int,
            cost: Double,
            battleValue: Double,
            rulesReference: String,
            minimalRange: Int,
            shortRange: Int,
            mediumRange: Int,
            longRange: Int,
            extremeRange: Int,
            shortWaterRange: Int,
            mediumWaterRange: Int,
            longWaterRange: Int,
            extremeWaterRange: Int,
            minimalRangeDamage: Int,
            shortRangeDamage: Int,
            mediumRangeDamage: Int,
            longRangeDamage: Int,
            extremeRangeDamage: Int,
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
            self.minimalRange = minimalRange
            self.shortRange = shortRange
            self.mediumRange = mediumRange
            self.longRange = longRange
            self.extremeRange = extremeRange
            self.shortWaterRange = shortWaterRange
            self.mediumWaterRange = mediumWaterRange
            self.longWaterRange = longWaterRange
            self.extremeWaterRange = extremeWaterRange
            self.minimalRangeDamage = minimalRangeDamage
            self.shortRangeDamage = shortRangeDamage
            self.mediumRangeDamage = mediumRangeDamage
            self.longRangeDamage = longRangeDamage
            self.extremeRangeDamage = extremeRangeDamage
            self.publishedAt = publishedAt

            self.$techBase.id = techBase.id!
            self.$techLevelStatic.id = techLevelStatic.id!
        }
    }
}
