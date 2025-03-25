//
//  AddStartYearToEras.swift
//
// Adds the Start Year to Era
//
// Author: Richard J Hancock
// Date: 2024/02/12
//

import Fluent
import FluentSQL

extension BattleTech {
    struct AddStartYearToEras: AsyncMigration {
        func prepare(on database: any Database) async throws {
            try await database.schema(for: BattleTech.Era.self)
                .field(BattleTech.Era.V20240409.startYear, .int)
                .update()
        }

        func revert(on database: any Database) async throws {
            try await database.schema(for: BattleTech.Era.self)
                .deleteField(BattleTech.Era.V20240409.startYear)
                .update()
        }
    }
}

extension BattleTech.Era {
    enum V20240409 {
        static let startYear = FieldKey(stringLiteral: "start_year")
    }
}
