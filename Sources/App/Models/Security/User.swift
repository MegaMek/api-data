//
//  User.swift
//
//  User model
//
//  Created by Richard Hancock on 12/27/22.
//

import Fluent
import Vapor

extension Security {
    enum UserError: Error, LocalizedError {
        case passwordsDoNotMatch
        case cantModifyAdminAsAnAdmin
        case userNotActive
        case cantEmailUnconfirmedWithoutEmailAddress

        public var errorDescription: String? {
            switch self {
            case .passwordsDoNotMatch:
                return "Passwords Do Not Match"

            case .cantModifyAdminAsAnAdmin:
                return "For safety, can't change the role of an admin as an admin."

            case .userNotActive:
                return "User is not currently active."

            case .cantEmailUnconfirmedWithoutEmailAddress:
                return "Unable to send an email to an unconfirmed address with an unconfirmed email"
            }
        }
    }

    final class User: Model, Content, @unchecked Sendable {
        public static let schema: String = Security.User.V20221227.schemaName
        public static let space: String? = Security.User.V20221227.spaceName

        @ID
        var id: UUID?

        @OptionalField(key: Security.User.V20230818.firstName)
        var firstName: String?

        @OptionalField(key: Security.User.V20230818.lastName)
        var lastName: String?

        @Field(key: Security.User.V20221227.name)
        var name: String

        @Field(key: Security.User.V20221227.username)
        var username: String

        @Field(key: Security.User.V20221227.password)
        var password: String

        @Field(key: Security.User.V20221227.email)
        var email: String

        @OptionalField(key: Security.User.V20230818A.unconfirmedEmail)
        var unconfirmedEmail: String?

        @Field(key: Security.User.V20221227.role)
        var role: UserRole

        @OptionalField(key: Security.User.V20230316.confirmedAt)
        var confirmedAt: Date?

        @Timestamp(key: Security.User.V20221227.createdAt, on: .create)
        var createdAt: Date?

        @Timestamp(key: Security.User.V20221227.updatedAt, on: .update)
        var updatedAt: Date?

        @Timestamp(key: Security.User.V20221227.deletedAt, on: .delete)
        var deletedAt: Date?

        init() {}

        init(
            id: UUID? = nil,
            name: String,
            username: String,
            email: String,
            role: Security.UserRole = .nonConfirmed
        ) {
            self.name = name
            self.username = username
            self.email = email
            self.role = role
        }

        init(
            id: UUID? = nil,
            firstName: String,
            lastName: String,
            username: String,
            email: String,
            role: Security.UserRole = .nonConfirmed
        ) {
            self.firstName = firstName
            self.lastName = lastName
            self.username = username
            self.email = email
            self.role = role

            self.name = "\(firstName) \(lastName)"
        }
    }
}

extension Security.User {
    final class Profile: Content {
        let id: UUID
        let name: String
        let firstName: String
        let lastName: String
        let username: String
        let email: String
        let role: Security.UserRole
        let createdAt: Date

        init(
            id: UUID,
            name: String,
            firstName: String,
            lastName: String,
            username: String,
            email: String,
            role: Security.UserRole,
            createdAt: Date
        ) {
            self.id = id
            self.name = name
            self.firstName = firstName
            self.lastName = lastName
            self.username = username
            self.email = email
            self.role = role
            self.createdAt = createdAt
        }
    }

    func convertToProfile() -> Security.User.Profile {
        Security.User.Profile(
            id: id!,
            name: name,
            firstName: firstName ?? "",
            lastName: lastName ?? "",
            username: username,
            email: email,
            role: role,
            createdAt: createdAt!
        )
    }
}

extension Security.User {
    final class Public: Content {
        let id: UUID
        let name: String
        let username: String
        let role: Security.UserRole

        init(id: UUID, name: String, username: String, role: Security.UserRole) {
            self.id = id
            self.name = name
            self.username = username
            self.role = role
        }
    }

    func convertToPublic() -> Security.User.Public {
        Security.User.Public(id: id!, name: name, username: username, role: role)
    }
}

extension Security.User {
    func setPassword(_ password: String, confirm passwordConfirmation: String) throws {
        if password != passwordConfirmation {
            throw Abort(
                .badRequest, reason: Security.UserError.passwordsDoNotMatch.errorDescription)
        }

        self.password = try Bcrypt.hash(password)
    }

    func updateName(firstName: String, lastName: String) {
        self.firstName = firstName
        self.lastName = lastName
        self.name = "\(firstName) \(lastName)"
    }
}

extension Security.User: ModelAuthenticatable {
    static var usernameKey: KeyPath<Security.User, Field<String>> {
        \Security.User.$username
    }

    static var passwordHashKey: KeyPath<Security.User, Field<String>> {
        \Security.User.$password
    }

    func verify(password: String) throws -> Bool {
        guard self.active() else {
            throw Abort(.unauthorized, reason: Security.UserError.userNotActive.errorDescription)
        }
        return try Bcrypt.verify(password, created: self.password)
    }
}

extension Collection where Element: Security.User {
    func convertToPublic() -> [Security.User.Public] {
        return self.map { $0.convertToPublic() }
    }

    func convertToProfile() -> [Security.User.Profile] {
        return self.map { $0.convertToProfile() }
    }
}
