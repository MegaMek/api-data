import Fluent
import Vapor

extension BattleTech.AmmoAlias {
  static func findOrCreate(
    tentativeAliases: [String],
    with database: Database
  ) async throws -> [BattleTech.AmmoAlias] {
    var aliases: [BattleTech.AmmoAlias] = []

    for alias in tentativeAliases {
      if let foundAlias = try await BattleTech.AmmoAlias.query(on: database)
        .filter(\.$name == alias)
        .first() {
          aliases.append(foundAlias)
      } else {
        let newAlias = BattleTech.AmmoAlias(name: alias)
        aliases.append(newAlias)
      }
    }

    return aliases
  }
}
