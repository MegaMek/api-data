import Fluent
import Vapor

extension BattleTech.TechLevel {
  static func findOrCreate(tentativeTechLevel: String, with database: Database) async throws
    -> BattleTech.TechLevel
  {
    if let foundTechLevel = try await BattleTech.TechLevel.query(on: database)
      .filter(\.$name == tentativeTechLevel)
      .first()
    {
      return foundTechLevel
    } else {
      let newTechLevel = BattleTech.TechLevel(name: tentativeTechLevel)
      do {
        try await newTechLevel.save(on: database)
      } catch {
        print(String(reflecting: error))
      }

      return newTechLevel
    }
  }
}
