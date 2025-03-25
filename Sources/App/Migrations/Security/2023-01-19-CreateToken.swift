//
//  CreateToken.swift
//
//
//  Created by Richard Hancock on 1/19/23.
//

import Fluent
import FluentSQL

extension Security {
    struct CreateToken: AsyncMigration {
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

        func revert(on database: any Database) async throws {
            try await database.schema(for: Security.Token.self).delete()
        }
    }
}

extension Security.Token {
    enum V20230119 {
        static let schemaName = "tokens"
        static let spaceName = "security"

        static let id = FieldKey(stringLiteral: "id")
        static let value = FieldKey(stringLiteral: "value")
        static let userID = FieldKey(stringLiteral: "user_id")

        static let createdAt = FieldKey(stringLiteral: "created_at")
    }
}
