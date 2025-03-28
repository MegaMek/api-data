//
//  AddConfirmedAtToUser.swift
//
//  Adds the ConfirmedAt field to User.
//
//  Created by Richard Hancock on 03/16/23.
//

import Fluent
import FluentSQL

extension Security {

    struct AddConfirmedAtToUser: AsyncMigration {
        func prepare(on database: any Database) async throws {
            try await database.schema(for: Security.User.self)
                .field(Security.User.V20230316.confirmedAt, .datetime)
                .update()
        }

        func revert(on database: any Database) async throws {
            try await database.schema(for: Security.User.self)
                .deleteField(Security.User.V20230316.confirmedAt)
                .update()
        }
    }
}

extension Security.User {
    enum V20230316 {
        static let confirmedAt = FieldKey(stringLiteral: "confirmed_at")
    }
}
