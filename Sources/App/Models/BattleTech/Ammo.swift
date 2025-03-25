import Fluent
import Vapor

extension BattleTech {
    final class Ammo: Model, Content, @unchecked Sendable {
        static let schema = BattleTech.Ammo.V20240327.schemaName
        public static let space: String? = BattleTech.Ammo.V20240327.spaceName

        @ID(key: .id)
        var id: UUID?

        @Field(key: BattleTech.Ammo.V20240327.name)
        var name: String

        @Parent(key: BattleTech.Ammo.V20240327.techBase)
        var techBase: BattleTech.TechBase

        @Siblings(through: BattleTech.AmmoRulePivot.self, from: \.$ammo, to: \.$rule)
        var rules: [BattleTech.Rule]

        @Field(key: BattleTech.Ammo.V20240327.techRating)
        var techRating: String

        @Parent(key: BattleTech.Ammo.V20240327.techLevelStatic)
        var techLevelStatic: BattleTech.TechLevel

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

        @Field(key: BattleTech.Ammo.V20240327.countAsFlak)
        var countAsFlak: Bool

        @Parent(key: BattleTech.Ammo.V20240327.munitionType)
        var munitionType: BattleTech.MunitionType

        @Field(key: BattleTech.Ammo.V20240327.damagePerShot)
        var damagePerShot: Int

        @Field(key: BattleTech.Ammo.V20240327.rackSize)
        var rackSize: Int

        @Field(key: BattleTech.Ammo.V20240327.shots)
        var shots: Int

        @Field(key: BattleTech.Ammo.V20240327.ammoRatio)
        var ammoRatio: Double

        @Field(key: BattleTech.Ammo.V20240327.isCapital)
        var isCapital: Bool

        @Field(key: BattleTech.Ammo.V20240327.kilogramPerShot)
        var kilogramPerShot: Double

        @Field(key: BattleTech.Ammo.V20240327.aeroUse)
        var aeroUse: Bool

        @Children(for: \.$ammo)
        var aliases: [BattleTech.AmmoAlias]

        @Field(key: BattleTech.Ammo.V20240327.publishedAt)
        var publishedAt: Date?

        @Timestamp(key: BattleTech.Ammo.V20240327.createdAt, on: .create)
        var createdAt: Date?

        @Timestamp(key: BattleTech.Ammo.V20240327.updatedAt, on: .update)
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
