import Fluent
import Vapor

extension BattleTech.TechBase {
  static func findOrCreate(tentativeTechBase: String, with database: Database) async throws
    -> BattleTech.TechBase {
    if let foundTechBase = try await BattleTech.TechBase.query(on: database)
      .filter(\.$name == tentativeTechBase)
      .first() {
      return foundTechBase
    } else {
      let newTechBase = BattleTech.TechBase(name: tentativeTechBase)
      do {
        try await newTechBase.save(on: database)
      } catch {
        print(String(reflecting: error))
      }

      return newTechBase
    }
  }
}
