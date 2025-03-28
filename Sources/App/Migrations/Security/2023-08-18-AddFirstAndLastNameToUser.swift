//
//  2023-08-18-AddFirstAndLastNameToUser.swift
//
//  Adds the FIrst and Last Name to User model.
//
//  Created by Richard Hancock on 03/16/23.
//

import Fluent
import FluentSQL

extension Security {
    struct AddFirstAndLastNameToUser: AsyncMigration {
        func prepare(on database: any Database) async throws {
            try await database.schema(for: Security.User.self)
                .field(Security.User.V20230818.firstName, .string)
                .field(Security.User.V20230818.lastName, .string)
                .update()
        }

        func revert(on database: any Database) async throws {
            try await database.schema(for: Security.User.self)
                .deleteField(Security.User.V20230818.firstName)
                .deleteField(Security.User.V20230818.lastName)
                .update()
        }
    }
}

extension Security.User {
    enum V20230818 {
        static let firstName = FieldKey(stringLiteral: "first_name")
        static let lastName = FieldKey(stringLiteral: "last_name")
    }
}
