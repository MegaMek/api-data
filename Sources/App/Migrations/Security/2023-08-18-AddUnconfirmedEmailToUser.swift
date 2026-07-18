///  2023-08-18-AddUnconfirmedEmailToUser.swift
///
///  Fluent migration (dated 2023-08-18) that adds the `unconfirmed_email` column to the
///  `security.users` table, holding a new email address pending re-confirmation.
//
//  2023-08-18-AddUnconfirmedEmailToUser.swift
//
//  Adds unconfirmed email to User model.
//
//  Created by Richard Hancock on 03/16/23.
//

import Fluent
import FluentSQL

extension Security {
    /// Adds the `unconfirmed_email` column to the `users` table.
    struct AddUnconfirmedEmailToUser: AsyncMigration {
        /// Adds the `unconfirmed_email` column to `users`.
        /// - Parameter database: The database connection to apply the migration on.
        /// - Throws: An error if the schema change fails to apply.
        func prepare(on database: any Database) async throws {
            try await database.schema(for: Security.User.self)
                .field(Security.User.V20230818A.unconfirmedEmail, .string)
                .update()
        }

        /// Removes the `unconfirmed_email` column from `users`.
        /// - Parameter database: The database connection to revert the migration on.
        /// - Throws: An error if the schema change fails to revert.
        func revert(on database: any Database) async throws {
            try await database.schema(for: Security.User.self)
                .deleteField(Security.User.V20230818A.unconfirmedEmail)
                .update()
        }
    }
}

extension Security.User {
    /// Versioned column-name namespace adding `unconfirmed_email` to ``Security/User`` as
    /// of this migration (2023-08-18).
    enum V20230818A {
        static let unconfirmedEmail = FieldKey(stringLiteral: "unconfirmed_email")
    }
}
