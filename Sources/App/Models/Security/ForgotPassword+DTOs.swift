//
//  ForgotPasswordDTOs.swift
//
//  DTOs related to ForgotPassword
//
//  Created by Richard Hancock on 4/2/23.
//

/// DTOs (Data Transfer Objects) for the forgot-password flow: requesting a reset email,
/// the template context used to render that email, and submitting a new password.
///
/// DTOs describe the exact JSON shape a client sends/receives for one endpoint, kept
/// separate from the Fluent `Model` so the wire format can differ from (and never
/// accidentally leak internal fields, like the password hash, from) the database record.

import Vapor

/// Payload submitted by a client to request a password-reset email.
struct ForgotPasswordDTO: Codable, Content {
    // The address to email, and the base URL the reset link should point back to (e.g. a
    // front-end app's domain, since this API doesn't know where its clients are hosted).
    var email: String
    var url: String
}

/// Template-rendering context passed to the email system when sending a password-reset
/// email; not sent over the API, just used internally to fill in the email body.
struct ForgotPasswordContext: Encodable {
    var resetToken: String
    var remoteURL: String
    var user: Security.User
}

/// Payload submitted by a client to complete a password reset: the reset token from the
/// emailed link plus the new password (entered twice for confirmation).
struct ForgotPasswordResetDTO: Codable, Content {
    var resetToken: String
    var password: String
    var passwordConfirmation: String
}
