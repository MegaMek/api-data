///  CreateToken.swift
///
///  Fluent migration (dated 2023-01-19) that creates the `security.tokens` table,
///  storing auth/session tokens tied to a ``Security/User`` via a foreign key.
//
//
//  Created by Richard Hancock on 1/19/23.
//

import Fluent
import FluentSQL

extension Security {
    /// Creates the `security.tokens` table.
    struct CreateToken: AsyncMigration {
        /// Creates the `tokens` table with its initial columns.
        /// - Parameter database: The database connection to apply the migration on.
        /// - Throws: An error if the schema change fails to apply.
        func prepare(on database: any Database) async throws {
            try await database.schema(for: Security.Token.self)
                .id()
                .field(Security.Token.V20230119.value, .string, .required)
                .field(
                    Security.Token.V20230119.userID,
                    .uuid,
                    .required,
                    .references(
                        Security.User.self,
                        Security.User.V20221227.id,
                        onDelete: .cascade)
                )
                .field(Security.Token.V20230119.createdAt, .datetime)
                .create()
        }

        /// Drops the `tokens` table.
        /// - Parameter database: The database connection to revert the migration on.
        /// - Throws: An error if the schema change fails to revert.
        func revert(on database: any Database) async throws {
            try await database.schema(for: Security.Token.self).delete()
        }
    }
}

extension Security.Token {
    /// Stable, versioned column-name namespace for ``Security/Token`` as of this migration
    /// (2023-01-19). Keeps the database column names fixed even if the Swift properties
    /// on the model are later renamed.
    enum V20230119 {
        static let schemaName = "tokens"
        static let spaceName = "security"

        static let id = FieldKey(stringLiteral: "id")
        static let value = FieldKey(stringLiteral: "value")
        static let userID = FieldKey(stringLiteral: "user_id")

        static let createdAt = FieldKey(stringLiteral: "created_at")
    }
}
