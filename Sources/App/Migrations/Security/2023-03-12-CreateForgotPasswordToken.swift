//
//  CreateForgotPasswordToken.swift
//
//  Tokens for Forgot Password.
//
//  Created by Richard Hancock on 03-12-23.
//

import Fluent
import FluentSQL

extension Security {
  struct CreateForgotPasswordToken: AsyncMigration {
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

    func revert(on database: any Database) async throws {
      try await database.schema(for: Security.ForgotPasswordToken.self).delete()
    }
  }
}

extension Security.ForgotPasswordToken {
  enum V20230312 {
    static let schemaName = "forgot_password_tokens"
    static let spaceName = "security"

    static let id = FieldKey(stringLiteral: "id")
    static let value = FieldKey(stringLiteral: "value")
    static let userID = FieldKey(stringLiteral: "user_id")

    static let createdAt = FieldKey(stringLiteral: "created_at")
  }
}
