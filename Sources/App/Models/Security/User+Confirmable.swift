//
//  User+Confirmable.swift
//
//  Methods related to confirming the email address of the user.
//
//  Created by Richard Hancock on 4/2/23.
//

/// Email-confirmation workflow methods on ``Security/User``: generating and sending
/// confirmation-link emails (for signup, and for both the old and new address when a user
/// changes their email), plus marking a user confirmed once they click the link.

import Fluent
import SendGrid
import Vapor

extension Security.User {
    /// Generates a ``Security/ConfirmationToken``, saves it, and emails the user a link to
    /// confirm their account after initial signup.
    /// - Parameters:
    ///   - req: The current request, used for database access and sending the email.
    ///   - remoteURL: Base URL of the front-end app, used to build the link in the email.
    /// - Throws: If token generation, saving, or sending the email fails.
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

    /// Generates a ``Security/ConfirmationToken`` and emails the user's *current* address
    /// to notify/confirm that an email-change request was made.
    /// - Parameters:
    ///   - req: The current request, used for database access and sending the email.
    ///   - remoteURL: Base URL of the front-end app, used to build the link in the email.
    /// - Throws: If token generation, saving, or sending the email fails.
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

    /// Generates a ``Security/ConfirmationToken`` and emails the user's *new* (pending,
    /// unconfirmed) address so they can confirm ownership of it before it replaces `email`.
    /// - Parameters:
    ///   - req: The current request, used for database access and sending the email.
    ///   - remoteURL: Base URL of the front-end app, used to build the link in the email.
    /// - Throws: If token generation, saving, or sending the email fails.
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

    /// Marks this user as confirmed: stamps `confirmedAt` with the current date, promotes
    /// the role from `.nonConfirmed` to `.registered`, and persists the change. Called once
    /// a submitted confirmation token has been validated.
    /// - Parameter db: The database connection to save on.
    /// - Throws: If saving the updated user fails.
    func confirm(on db: any Database) async throws {
        self.confirmedAt = Date()
        self.role = .registered
        try await self.save(on: db)
    }
}

/// Template-rendering context passed to the email system when sending any of the
/// confirmation emails above; not sent over the API, just used internally to fill in the
/// email body.
struct ConfirmUserContext: Encodable {
    var confirmToken: String
    var remoteURL: String
    var user: Security.User
}
