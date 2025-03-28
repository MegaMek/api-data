//
//  ConfirmationToken.swift
//
//  Confirmation Token storage for Users
//
//  Created by Richard Hancock on 3/16/23.
//

import Fluent
import Vapor

extension Security {
    final class ConfirmationToken: Model, Content, @unchecked Sendable {
        public static let schema: String = Security.ConfirmationToken.V20230316.schemaName
        public static let space: String? = Security.ConfirmationToken.V20230316.spaceName

        @ID
        var id: UUID?

        @Field(key: Security.ConfirmationToken.V20230316.value)
        var value: String

        @Parent(key: Security.ConfirmationToken.V20230316.userID)
        var user: User

        @Timestamp(key: Security.User.V20221227.createdAt, on: .create)
        var createdAt: Date?

        init() {}

        init(id: UUID? = nil, value: String, userID: User.IDValue) {
            self.id = id
            self.value = value
            self.$user.id = userID
        }
    }
}

extension Security.ConfirmationToken {
    static func generate(for user: Security.User) throws -> Security.ConfirmationToken {
        let random = [UInt8].random(count: 32).base64.base64URLSafe()
        return try Security.ConfirmationToken(value: random, userID: user.requireID())
    }

    var isValid: Bool {
        if let date = Calendar.current.date(byAdding: .hour, value: -72, to: Date()),
           let createdDate = self.createdAt,
           createdDate < date
        {
            return false
        } else {
            return true
        }
    }
}
