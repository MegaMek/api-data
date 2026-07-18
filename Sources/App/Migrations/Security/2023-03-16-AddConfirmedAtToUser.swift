///  AddConfirmedAtToUser.swift
///
///  Fluent migration (dated 2023-03-16) that adds the `confirmed_at` column to the
///  `security.users` table, recording when a user confirmed their email/account.
//
//  Adds the ConfirmedAt field to User.
//
//  Created by Richard Hancock on 03/16/23.
//

import Fluent
import FluentSQL

extension Security {

    /// Adds the `confirmed_at` column to the `users` table.
    struct AddConfirmedAtToUser: AsyncMigration {
        /// Adds the `confirmed_at` column to `users`.
        /// - Parameter database: The database connection to apply the migration on.
        /// - Throws: An error if the schema change fails to apply.
        func prepare(on database: any Database) async throws {
            try await database.schema(for: Security.User.self)
                .field(Security.User.V20230316.confirmedAt, .datetime)
                .update()
        }

        /// Removes the `confirmed_at` column from `users`.
        /// - Parameter database: The database connection to revert the migration on.
        /// - Throws: An error if the schema change fails to revert.
        func revert(on database: any Database) async throws {
            try await database.schema(for: Security.User.self)
                .deleteField(Security.User.V20230316.confirmedAt)
                .update()
        }
    }
}

extension Security.User {
    /// Versioned column-name namespace adding `confirmed_at` to ``Security/User`` as of
    /// this migration (2023-03-16). Keeps the column name fixed even if the corresponding
    /// Swift property is later renamed.
    enum V20230316 {
        static let confirmedAt = FieldKey(stringLiteral: "confirmed_at")
    }
}
