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
  struct AddUnconfirmedEmailToUser: AsyncMigration {
    func prepare(on database: any Database) async throws {
      try await database.schema(for: Security.User.self)
        .field(Security.User.V20230818A.unconfirmedEmail, .string)
        .update()
    }

    func revert(on database: any Database) async throws {
      try await database.schema(for: Security.User.self)
        .deleteField(Security.User.V20230818A.unconfirmedEmail)
        .update()
    }
  }
}

extension Security.User {
  enum V20230818A {
    static let unconfirmedEmail = FieldKey(stringLiteral: "unconfirmed_email")
  }
}
