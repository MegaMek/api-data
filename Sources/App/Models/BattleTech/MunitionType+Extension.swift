import Fluent
import Vapor

extension BattleTech.MunitionType {
  static func findOrCreate(
    tentativeMunitionType: String,
    with database: Database
  ) async throws -> BattleTech.MunitionType {
    if let foundMunitionType = try await BattleTech.MunitionType.query(on: database)
      .filter(\.$name == tentativeMunitionType)
      .first()
    {
      return foundMunitionType
    } else {
      let newMunitionType = BattleTech.MunitionType(name: tentativeMunitionType)
      do {
        try await newMunitionType.save(on: database)
      } catch {
        print(String(reflecting: error))
      }

      return newMunitionType
    }
  }
}
