//
//  Token.swift
//
//  Token storage for Users
//
//  Created by Richard Hancock on 1/19/23.
//

import Fluent
import Vapor

extension Security {
  final class Token: Model, Content, @unchecked Sendable {
    public static let schema: String = Security.Token.V20230119.schemaName
    public static let space: String? = Security.Token.V20230119.spaceName

    @ID
    var id: UUID?

    @Field(key: Security.Token.V20230119.value)
    var value: String

    @Parent(key: Security.Token.V20230119.userID)
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

extension Security.Token {
  static func generate(for user: User) throws -> Security.Token {
    let random = [UInt8].random(count: 16).base64.base64URLSafe()
    return try Security.Token(value: random, userID: user.requireID())
  }
}

extension Security.Token: ModelTokenAuthenticatable {
    static var valueKey: KeyPath<Security.Token, Field<String>> {
        \Security.Token.$value
    }
    
    static var userKey: KeyPath<Security.Token, Parent<Security.User>> {
        \Security.Token.$user
    }
    
  typealias User = App.Security.User

  var isValid: Bool {
    if let date = Calendar.current.date(byAdding: .day, value: -14, to: Date()),
      let createdDate = self.createdAt,
      createdDate < date
    {
      return false
    } else {
      return true
    }
  }
}
