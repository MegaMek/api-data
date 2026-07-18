//
//  ConfirmationTokenDTOs.swift
//
//  DTOs related to Confirmation Token
//
//  Created by Richard Hancock on 4/2/23.
//

/// DTO (Data Transfer Object) for the email-confirmation request.
///
/// A DTO describes the exact JSON shape a client sends/receives for one endpoint, kept
/// separate from the Fluent `Model` so the wire format can differ from (and never
/// accidentally leak internal fields of) the database record.

import Vapor

/// Payload submitted by a client to confirm an email address; carries just the token value
/// from the confirmation link/email, which is looked up against ``Security/ConfirmationToken``.
struct ConfirmUserDTO: Codable, Content {
    var confirmToken: String
}
