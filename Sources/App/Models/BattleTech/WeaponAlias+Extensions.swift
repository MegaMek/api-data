import Fluent
import Vapor

extension BattleTech.WeaponAlias {
  static func findOrCreate(
    tentativeAliases: [String],
    with database: Database
  ) async throws -> [BattleTech.WeaponAlias] {
    var aliases: [BattleTech.WeaponAlias] = []

    for alias in tentativeAliases {
      if let foundAlias = try await BattleTech.WeaponAlias.query(on: database)
        .filter(\.$name == alias)
        .first() {
        aliases.append(foundAlias)
      } else {
        let newAlias = BattleTech.WeaponAlias(name: alias)
        aliases.append(newAlias)
      }
    }

    return aliases
  }
}
