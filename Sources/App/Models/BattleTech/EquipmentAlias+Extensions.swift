import Fluent
import Vapor

extension BattleTech.EquipmentAlias {
  static func findOrCreate(
    tentativeAliases: [String],
    with database: Database
  ) async throws -> [BattleTech.EquipmentAlias] {
    var aliases: [BattleTech.EquipmentAlias] = []

    for alias in tentativeAliases {
      if let foundAlias = try await BattleTech.EquipmentAlias.query(on: database)
        .filter(\.$name == alias)
        .first() {
          aliases.append(foundAlias)
      } else {
        let newAlias = BattleTech.EquipmentAlias(name: alias)
        aliases.append(newAlias)
      }
    }

    return aliases
  }
}
