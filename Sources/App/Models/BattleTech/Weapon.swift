import Fluent
import Vapor

extension BattleTech {
    final class Weapon: Model, Content, @unchecked Sendable {
        static let schema = BattleTech.Weapon.V20240316.schemaName
        public static let space: String? = BattleTech.Weapon.V20240316.spaceName

        @ID(key: .id)
        var id: UUID?

        @Field(key: BattleTech.Weapon.V20240316.name)
        var name: String

        @Parent(key: BattleTech.Weapon.V20240316.techBase)
        var techBase: BattleTech.TechBase

        @Siblings(through: BattleTech.RuleWeaponPivot.self, from: \.$weapon, to: \.$rule)
        var rules: [BattleTech.Rule]

        @Field(key: BattleTech.Weapon.V20240316.techRating)
        var techRating: String

        @Parent(key: BattleTech.Weapon.V20240316.techLevelStatic)
        var techLevelStatic: BattleTech.TechLevel

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

        @Field(key: BattleTech.Weapon.V20240316.shortWaterRange)
        var shortWaterRange: Int

        @Field(key: BattleTech.Weapon.V20240316.mediumWaterRange)
        var mediumWaterRange: Int

        @Field(key: BattleTech.Weapon.V20240316.longWaterRange)
        var longWaterRange: Int

        @Field(key: BattleTech.Weapon.V20240316.extremeWaterRange)
        var extremeWaterRange: Int

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

        @Children(for: \.$weapon)
        var aliases: [BattleTech.WeaponAlias]

        @Field(key: BattleTech.Weapon.V20240316.publishedAt)
        var publishedAt: Date?

        @Timestamp(key: BattleTech.Weapon.V20240316.createdAt, on: .create)
        var createdAt: Date?

        @Timestamp(key: BattleTech.Weapon.V20240316.updatedAt, on: .update)
        var updatedAt: Date?

        init() {
            self.publishedAt = Calendar.current.date(byAdding: .day, value: -60, to: Date())
        }

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
