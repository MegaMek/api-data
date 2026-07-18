//
//  SendEMailPayload.swift
//  mul-api
//
//  Created by Richard Hancock on 5/9/25.
//


import Queues
import SendGrid
import Vapor

/// The serializable payload dispatched to the job queue for an outgoing email,
/// built by ``EmailHandler`` from a rendered Leaf template. Carries everything
/// needed to construct a SendGrid email without depending on a live `Request`.
struct SendEMailPayload: Codable {
    /// Recipients and per-recipient substitution data/subject for the email.
    var personalizations: [Personalization<[String: String]>]
    /// The body content (e.g. the rendered plain-text template) and its MIME type.
    var content: [EmailContent]
}

/// A background `Job` (from Vapor's Queues package) that actually sends an email
/// via the SendGrid API. Kept off the request thread so an HTTP handler doesn't
/// have to wait on an external mail provider; dispatched by ``EmailHandler/send(emailConfig:emailContent:on:)``.
struct SendEmailJob: AsyncJob {
    /// The data handed to this job when it is dispatched: the recipients, subject,
    /// and body content to send.
    typealias Payload = SendEMailPayload

    /// The fixed sender identity used for all outgoing mail from this service.
    let fromEmail = EmailAddress(
        email: "noreply@fasa.dev",
        name: "FASA Central API Service"
    )

    /// Executes the job: builds a `SendGridEmail` from the payload and sends it
    /// through the app's SendGrid client. SendGrid-specific failures are logged
    /// and swallowed rather than rethrown, so a bad/rejected email does not cause
    /// the job to endlessly retry.
    ///
    /// - Parameters:
    ///   - context: The `QueueContext` providing access to the application (and
    ///     its configured SendGrid client) while the job runs.
    ///   - payload: The recipients, subject, and content to send.
    /// - Throws: Does not rethrow `SendGridError`s (they are logged instead); other
    ///   errors propagate normally.
    func dequeue(_ context: Queues.QueueContext, _ payload: SendEMailPayload) async throws {
        let email = SendGridEmail(
            personalizations: payload.personalizations,
            from: fromEmail,
            content: payload.content
        )

        do {
            _ = try await context.application.sendgrid.client.send(email: email)
        } catch let error as SendGridError {
            print(error.localizedDescription)
        }
    }
}
