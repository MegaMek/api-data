//
//  ForgotPasswordToken.swift
//
//  Forgot Password Token storage for Users
//
//  Created by Richard Hancock on 3/12/23.
//

import Fluent
import Vapor

extension Security {
  final class ForgotPasswordToken: Model, Content, @unchecked Sendable {
    public static let schema: String = Security.ForgotPasswordToken.V20230312.schemaName
    public static let space: String? = Security.ForgotPasswordToken.V20230312.spaceName

    @ID
    var id: UUID?

    @Field(key: Security.ForgotPasswordToken.V20230312.value)
    var value: String

    @Parent(key: Security.ForgotPasswordToken.V20230312.userID)
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

extension Security.ForgotPasswordToken {
  static func generate(for user: Security.User) throws -> Security.ForgotPasswordToken {
    let random = [UInt8].random(count: 24).base64.base64URLSafe()
    return try Security.ForgotPasswordToken(value: random, userID: user.requireID())
  }

  var isValid: Bool {
    if let date = Calendar.current.date(byAdding: .hour, value: -1, to: Date()),
      let createdDate = self.createdAt,
      createdDate < date
    {
      return false
    } else {
      return true
    }
  }
}
