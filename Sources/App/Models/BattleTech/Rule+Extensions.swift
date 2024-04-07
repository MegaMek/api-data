import Fluent
import Vapor

extension BattleTech.Rule {
  static func findOrCreate(tentativeRules: [String], with database: Database) async throws
    -> [BattleTech.Rule] {
    var rules: [BattleTech.Rule] = []

    for rule in tentativeRules {
      if let foundRule = try await BattleTech.Rule.query(on: database)
        .filter(\.$name == rule)
        .first() {
        rules.append(foundRule)
      } else {
        let newRule = BattleTech.Rule(name: rule)
        do {
          try await newRule.save(on: database)
        } catch {
          print(String(reflecting: error))
        }

        rules.append(newRule)
      }
    }

    return rules
  }
}
