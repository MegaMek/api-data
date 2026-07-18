///  CreateForgotPasswordToken.swift
///
///  Fluent migration (dated 2023-03-12) that creates the `security.forgot_password_tokens`
///  table, storing password-reset tokens tied to a ``Security/User`` via a foreign key.
//
//  Tokens for Forgot Password.
//
//  Created by Richard Hancock on 03-12-23.
//

import Fluent
import FluentSQL

extension Security {
    /// Creates the `security.forgot_password_tokens` table.
    struct CreateForgotPasswordToken: AsyncMigration {
        /// Creates the `forgot_password_tokens` table with its initial columns.
        /// - Parameter database: The database connection to apply the migration on.
        /// - Throws: An error if the schema change fails to apply.
        func prepare(on database: any Database) async throws {
            try await database.schema(for: Security.ForgotPasswordToken.self)
                .id()
                .field(Security.ForgotPasswordToken.V20230312.value, .string, .required)
                .field(
                    Security.ForgotPasswordToken.V20230312.userID,
                    .uuid,
                    .required,
                    .references(
                        Security.User.self,
                        Security.User.V20221227.id,
                        onDelete: .cascade)
                )
                .field(Security.ForgotPasswordToken.V20230312.createdAt, .datetime)
                .create()
        }

        /// Drops the `forgot_password_tokens` table.
        /// - Parameter database: The database connection to revert the migration on.
        /// - Throws: An error if the schema change fails to revert.
        func revert(on database: any Database) async throws {
            try await database.schema(for: Security.ForgotPasswordToken.self).delete()
        }
    }
}

extension Security.ForgotPasswordToken {
    /// Stable, versioned column-name namespace for ``Security/ForgotPasswordToken`` as of
    /// this migration (2023-03-12). Keeps the database column names fixed even if the
    /// Swift properties on the model are later renamed.
    enum V20230312 {
        static let schemaName = "forgot_password_tokens"
        static let spaceName = "security"

        static let id = FieldKey(stringLiteral: "id")
        static let value = FieldKey(stringLiteral: "value")
        static let userID = FieldKey(stringLiteral: "user_id")

        static let createdAt = FieldKey(stringLiteral: "created_at")
    }
}
