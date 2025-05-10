//
//  SendEMailPayload.swift
//  mul-api
//
//  Created by Richard Hancock on 5/9/25.
//


import Queues
import SendGrid
import Vapor

struct SendEMailPayload: Codable {
    var personalizations: [Personalization<[String: String]>]
    var content: [EmailContent]
}

struct SendEmailJob: AsyncJob {
    typealias Payload = SendEMailPayload

    let fromEmail = EmailAddress(
        email: "noreply@fasa.dev",
        name: "FASA Central API Service"
    )

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
