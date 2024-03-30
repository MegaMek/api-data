import Fluent
import Vapor

extension BattleTech.MunitionType {
  static func findOrCreate(
    tentativeMunitionType: String,
    with database: Database
  ) async throws -> BattleTech.MunitionType {
    if let foundMunitionType = try await BattleTech.MunitionType.query(on: database)
      .filter(\.$name == tentativeMunitionType)
      .first() {
        return foundMunitionType
    } else {
      let newMunitionType = BattleTech.MunitionType(name: tentativeMunitionType)
      try await newMunitionType.save(on: database)
      return newMunitionType
    }
  }
}
