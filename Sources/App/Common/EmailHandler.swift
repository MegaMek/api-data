//
//  EmailHandler.swift
//  mul-api
//
//  Created by Richard Hancock on 5/9/25.
//

import Fluent
import SendGrid
import Vapor

/// Helper for rendering Leaf templates into email bodies and queuing them for
/// delivery via ``SendEmailJob``, rather than sending synchronously on the
/// request thread. Used by the user-auth flows (e.g. account confirmation,
/// email-change confirmation).
enum EmailHandler {
    /// Renders a Leaf template as plain-text and queues it for delivery to a
    /// user's confirmed email address.
    ///
    /// - Parameters:
    ///   - to: The `Security.User` to email; uses `to.email`.
    ///   - subject: The email subject line.
    ///   - body: The Leaf template name/path to render as the email body.
    ///   - context: The `Encodable` context passed to the Leaf renderer.
    ///   - req: The current `Request`, used to access Leaf rendering and the job queue.
    /// - Throws: Rethrows errors from Leaf rendering or job dispatch.
    static func sendEmail(
        _ to: Security.User,
        subject: String,
        body: String,
        context: any Encodable,
        on req: Request
    ) async throws {
        let emailContentView: View = try await req.leaf.render(body, context).get()

        let toEmail = EmailAddress(
            email: to.email,
            name: to.name
        )

        let emailConfig = Personalization(
            to: [toEmail],
            subject: subject
        )

        let emailContent = EmailContent(
            type: "text/plain",
            value: String(buffer: emailContentView.data)
        )

        try await EmailHandler.send(emailConfig: emailConfig, emailContent: emailContent, on: req)
    }

    /// Renders a Leaf template as plain-text and queues it for delivery to a
    /// user's pending (not-yet-confirmed) new email address, as part of the
    /// email-change confirmation flow.
    ///
    /// - Parameters:
    ///   - to: The `Security.User` whose `unconfirmedEmail` should be messaged.
    ///   - subject: The email subject line.
    ///   - body: The Leaf template name/path to render as the email body.
    ///   - context: The `Encodable` context passed to the Leaf renderer.
    ///   - req: The current `Request`, used to access Leaf rendering and the job queue.
    /// - Throws: `Security.UserError.cantEmailUnconfirmedWithoutEmailAddress` if the
    ///   user has no pending unconfirmed email address; otherwise rethrows errors
    ///   from Leaf rendering or job dispatch.
    static func sendEmailChange(
        _ to: Security.User,
        subject: String,
        body: String,
        context: any Encodable,
        on req: Request
    ) async throws {
        guard let unconfirmedEmail = to.unconfirmedEmail else {
            throw Security.UserError.cantEmailUnconfirmedWithoutEmailAddress
        }

        let emailContentView: View = try await req.leaf.render(body, context).get()

        let toEmail = EmailAddress(
            email: unconfirmedEmail,
            name: to.name
        )

        let emailConfig = Personalization(
            to: [toEmail],
            subject: subject
        )

        let emailContent = EmailContent(
            type: "text/plain",
            value: String(buffer: emailContentView.data)
        )

        try await EmailHandler.send(emailConfig: emailConfig, emailContent: emailContent, on: req)
    }

    /// Wraps a prepared personalization and content into a ``SendEMailPayload``
    /// and dispatches it to the queue so ``SendEmailJob`` can send it via SendGrid.
    ///
    /// - Parameters:
    ///   - emailConfig: The recipient(s) and subject for the message.
    ///   - emailContent: The rendered body content and MIME type.
    ///   - req: The current `Request`, used to access the job queue.
    /// - Throws: Rethrows errors from job dispatch.
    static func send(emailConfig: Personalization<[String: String]>, emailContent: EmailContent, on req: Request) async throws {
        let payload = SendEMailPayload(personalizations: [emailConfig], content: [emailContent])
        try await req.queue.dispatch(SendEmailJob.self, payload)
    }
}
