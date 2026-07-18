///  CreateConfirmationToken.swift
///
///  Fluent migration (dated 2023-03-16) that creates the `security.confirmation_tokens`
///  table, storing email/account-confirmation tokens tied to a ``Security/User`` via a
///  foreign key.
//
//  Tokens for Confirmation.
//
//  Created by Richard Hancock on 03-12-26.
//

import Fluent
import FluentSQL

extension Security {
    /// Creates the `security.confirmation_tokens` table.
    struct CreateConfirmationToken: AsyncMigration {
        /// Creates the `confirmation_tokens` table with its initial columns.
        /// - Parameter database: The database connection to apply the migration on.
        /// - Throws: An error if the schema change fails to apply.
        func prepare(on database: any Database) async throws {
            try await database.schema(for: Security.ConfirmationToken.self)
                .id()
                .field(Security.ConfirmationToken.V20230316.value, .string, .required)
                .field(
                    Security.ConfirmationToken.V20230316.userID,
                    .uuid,
                    .required,
                    .references(
                        Security.User.self,
                        Security.User.V20221227.id,
                        onDelete: .cascade)
                )
                .field(Security.ConfirmationToken.V20230316.createdAt, .datetime)
                .create()
        }

        /// Drops the `confirmation_tokens` table.
        /// - Parameter database: The database connection to revert the migration on.
        /// - Throws: An error if the schema change fails to revert.
        func revert(on database: any Database) async throws {
            try await database.schema(for: Security.ConfirmationToken.self).delete()
        }
    }
}

extension Security.ConfirmationToken {
    /// Stable, versioned column-name namespace for ``Security/ConfirmationToken`` as of
    /// this migration (2023-03-16). Keeps the database column names fixed even if the
    /// Swift properties on the model are later renamed.
    enum V20230316 {
        static let schemaName = "confirmation_tokens"
        static let spaceName = "security"

        static let id = FieldKey(stringLiteral: "id")
        static let value = FieldKey(stringLiteral: "value")
        static let userID = FieldKey(stringLiteral: "user_id")

        static let createdAt = FieldKey(stringLiteral: "created_at")
    }
}
