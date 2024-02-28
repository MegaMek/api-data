// Era Importer Structure Definition and functions
//
// Author: Richard J Hancock
// Date: 2024/02/19

import FluentKit
import Foundation
import Vapor

extension Importers {
    struct Eras: Codable {
        var era: [Importers.Era]
    }

    struct Era: Codable {
        var code: String
        var name: String
        var end: Int?
        var flag: String
        var icon: String?
        var mulid: Int?
    }
}

extension BattleTech.Era {
    static func findOrNew(importableEra: Importers.Era, on database: Database) async throws -> BattleTech.Era {
        guard let foundEra = try await BattleTech.Era.query(on: database)
            .filter(\.$code == importableEra.code)
            .first() else {
                return BattleTech.Era(
                    code: importableEra.code,
                    name: importableEra.name,
                    endYear: importableEra.end ?? -1,
                    flag: importableEra.flag,
                    icon: importableEra.icon ?? nil,
                    mulId: importableEra.mulid ?? -1
                )
            }

        foundEra.name =  importableEra.name
        foundEra.endYear = importableEra.end ?? -1
        foundEra.flag = importableEra.flag
        foundEra.icon = importableEra.icon ?? nil
        foundEra.mulId = importableEra.mulid ?? -1

        return foundEra
    }
}
