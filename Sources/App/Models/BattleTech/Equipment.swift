import Fluent
import Vapor

extension BattleTech {
  final class Equipment: Model, Content {
    static let schema = BattleTech.Equipment.V20240330.schemaName
    public static let space: String? = BattleTech.Equipment.V20240330.spaceName

    @ID(key: .id)
    var id: UUID?

    @Field(key: BattleTech.Equipment.V20240330.name)
    var name: String

    @Parent(key: BattleTech.Equipment.V20240330.techBase)
    var techBase: BattleTech.TechBase

    @Siblings(through: BattleTech.EquipmentRulePivot.self, from: \.$equipment, to: \.$rule)
    var rules: [BattleTech.Rule]

    @Field(key: BattleTech.Equipment.V20240330.techRating)
    var techRating: String

    @Parent(key: BattleTech.Equipment.V20240330.techLevelStatic)
    var techLevelStatic: BattleTech.TechLevel

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

    @Children(for: \.$equipment)
    var aliases: [BattleTech.EquipmentAlias]

    @Field(key: BattleTech.Equipment.V20240330.publishedAt)
    var publishedAt: Date?

    @Timestamp(key: BattleTech.Equipment.V20240330.createdAt, on: .create)
    var createdAt: Date?

    @Timestamp(key: BattleTech.Equipment.V20240330.updatedAt, on: .update)
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
