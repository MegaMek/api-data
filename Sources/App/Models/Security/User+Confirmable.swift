//
//  User+Confirmable.swift
//
//  Methods related to confirming the email address of the user.
//
//  Created by Richard Hancock on 4/2/23.
//

import Fluent
import SendGrid
import Vapor

extension Security.User {
    func sendConfirmEmail(_ req: Request, remoteURL: String) async throws {

        let token = try Security.ConfirmationToken.generate(for: self)
        try await token.save(on: req.db)

        let context = ConfirmUserContext(
            confirmToken: token.value,
            remoteURL: remoteURL,
            user: self
        )


        _ = try await EmailHandler.sendEmail(
            self,
            subject: "Confirm Email",
            body: "emails/confirmAccount",
            context: context,
            on: req)
    }

    func sendConfirmEmailChange(_ req: Request, remoteURL: String) async throws {
        let token = try Security.ConfirmationToken.generate(for: self)
        try await token.save(on: req.db)

        let context = ConfirmUserContext(
            confirmToken: token.value,
            remoteURL: remoteURL,
            user: self
        )

        _ = try await EmailHandler.sendEmail(
            self,
            subject: "Confirm Email Change Request",
            body: "emails/updateEmail",
            context: context,
            on: req)
    }

    func sendNewEmailChange(_ req: Request, remoteURL: String) async throws {
        let token = try Security.ConfirmationToken.generate(for: self)
        try await token.save(on: req.db)

        let context = ConfirmUserContext(
            confirmToken: token.value,
            remoteURL: remoteURL,
            user: self
        )

        _ = try await EmailHandler.sendEmailChange(
            self,
            subject: "Confirm New Email",
            body: "emails/confirmAccount",
            context: context,
            on: req)
    }

    func confirm(on db: any Database) async throws {
        self.confirmedAt = Date()
        self.role = .registered
        try await self.save(on: db)
    }
}

struct ConfirmUserContext: Encodable {
    var confirmToken: String
    var remoteURL: String
    var user: Security.User
}
