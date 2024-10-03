//
//  CreateConfirmationToken.swift
//
//  Tokens for Confirmation.
//
//  Created by Richard Hancock on 03-12-26.
//

import Fluent
import FluentSQL

extension Security {
  struct CreateConfirmationToken: AsyncMigration {
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

    func revert(on database: any Database) async throws {
      try await database.schema(for: Security.ConfirmationToken.self).delete()
    }
  }
}

extension Security.ConfirmationToken {
  enum V20230316 {
    static let schemaName = "confirmation_tokens"
    static let spaceName = "security"

    static let id = FieldKey(stringLiteral: "id")
    static let value = FieldKey(stringLiteral: "value")
    static let userID = FieldKey(stringLiteral: "user_id")

    static let createdAt = FieldKey(stringLiteral: "created_at")
  }
}
