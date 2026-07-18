///  CreateUser.swift
///
///  Fluent migration (dated 2022-12-27) that creates the `security.users` table, the
///  core user-account table backing authentication (username, password hash, email,
///  role, timestamps).
///
///  Fluent migrations are versioned, ordered database-schema changes. Each type conforms
///  to ``AsyncMigration``, implementing `prepare(on:)` to apply the change and `revert(on:)`
///  to undo it. Migration files are named with a date prefix (here, 2022-12-27) because
///  migrations must run in a strict, one-directional order matching how the schema
///  actually evolved in production — running them out of order could apply a later change
///  before the schema it depends on exists.
//
//
//  Created by Richard Hancock on 12/27/22.
//

import Fluent
import FluentSQL

extension Security {
    /// Creates the `security.users` table.
    struct CreateUser: AsyncMigration {
        /// Creates the `users` table with its initial columns.
        /// - Parameter database: The database connection to apply the migration on.
        /// - Throws: An error if the schema change fails to apply.
        func prepare(on database: any Database) async throws {
            try await database.schema(for: Security.User.self)
                .id()
                .field(Security.User.V20221227.name, .string, .required)
                .field(Security.User.V20221227.username, .string, .required)
                .field(Security.User.V20221227.password, .string, .required)
                .field(Security.User.V20221227.email, .string, .required)
                .field(Security.User.V20221227.role, .string, .required)
                .field(Security.User.V20221227.createdAt, .datetime)
                .field(Security.User.V20221227.updatedAt, .datetime)
                .field(Security.User.V20221227.deletedAt, .datetime)
                .unique(on: Security.User.V20221227.username)
                .unique(on: Security.User.V20221227.email)
                .create()
        }

        /// Drops the `users` table.
        /// - Parameter database: The database connection to revert the migration on.
        /// - Throws: An error if the schema change fails to revert.
        func revert(on database: any Database) async throws {
            try await database.schema(for: Security.User.self).delete()
        }
    }
}

extension Security.User {
    /// Stable, versioned column-name namespace for ``Security/User`` as of this migration
    /// (2022-12-27).
    ///
    /// A ``FieldKey`` namespace enum like this pins the actual database column names (e.g.
    /// `"username"`) independently of the Swift property names used on the model. If a
    /// Swift property is later renamed, the column name recorded here doesn't change, so
    /// the real database schema and any existing data aren't silently broken. Later
    /// migrations that alter this table add their own `V<date>` enum rather than editing
    /// this one, since this one reflects only what existed at this point in schema history.
    enum V20221227 {
        static let schemaName = "users"
        static let spaceName = "security"

        static let id = FieldKey(stringLiteral: "id")
        static let name = FieldKey(stringLiteral: "name")
        static let username = FieldKey(stringLiteral: "username")
        static let password = FieldKey(stringLiteral: "password")
        static let email = FieldKey(stringLiteral: "email")

        static let role = FieldKey(stringLiteral: "role")

        static let createdAt = FieldKey(stringLiteral: "created_at")
        static let updatedAt = FieldKey(stringLiteral: "updated_at")
        static let deletedAt = FieldKey(stringLiteral: "deleted_at")
    }
}
