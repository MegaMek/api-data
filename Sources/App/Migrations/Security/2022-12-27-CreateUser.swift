//
//  CreateUser.swift
//
//
//  Created by Richard Hancock on 12/27/22.
//

import Fluent
import FluentSQL

extension Security {
    struct CreateUser: AsyncMigration {
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

        func revert(on database: any Database) async throws {
            try await database.schema(for: Security.User.self).delete()
        }
    }
}

extension Security.User {
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
