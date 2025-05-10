//
//  EmailHandler.swift
//  mul-api
//
//  Created by Richard Hancock on 5/9/25.
//

import Fluent
import SendGrid
import Vapor

enum EmailHandler {
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

    static func send(emailConfig: Personalization<[String: String]>, emailContent: EmailContent, on req: Request) async throws {
        let payload = SendEMailPayload(personalizations: [emailConfig], content: [emailContent])
        try await req.queue.dispatch(SendEmailJob.self, payload)
    }
}
