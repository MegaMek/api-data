///  2023-08-18-AddFirstAndLastNameToUser.swift
///
///  Fluent migration (dated 2023-08-18) that adds the `first_name` and `last_name`
///  columns to the `security.users` table.
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
    /// Adds the `first_name` and `last_name` columns to the `users` table.
    struct AddFirstAndLastNameToUser: AsyncMigration {
        /// Adds the `first_name` and `last_name` columns to `users`.
        /// - Parameter database: The database connection to apply the migration on.
        /// - Throws: An error if the schema change fails to apply.
        func prepare(on database: any Database) async throws {
            try await database.schema(for: Security.User.self)
                .field(Security.User.V20230818.firstName, .string)
                .field(Security.User.V20230818.lastName, .string)
                .update()
        }

        /// Removes the `first_name` and `last_name` columns from `users`.
        /// - Parameter database: The database connection to revert the migration on.
        /// - Throws: An error if the schema change fails to revert.
        func revert(on database: any Database) async throws {
            try await database.schema(for: Security.User.self)
                .deleteField(Security.User.V20230818.firstName)
                .deleteField(Security.User.V20230818.lastName)
                .update()
        }
    }
}

extension Security.User {
    /// Versioned column-name namespace adding `first_name`/`last_name` to ``Security/User``
    /// as of this migration (2023-08-18).
    enum V20230818 {
        static let firstName = FieldKey(stringLiteral: "first_name")
        static let lastName = FieldKey(stringLiteral: "last_name")
    }
}
