//
//  ForgotPasswordDTOs.swift
//
//  DTOs related to ForgotPassword
//
//  Created by Richard Hancock on 4/2/23.
//

import Vapor

struct ForgotPasswordDTO: Codable, Content {
    var email: String
    var url: String
}

struct ForgotPasswordContext: Encodable {
    var resetToken: String
    var remoteURL: String
    var user: Security.User
}

struct ForgotPasswordResetDTO: Codable, Content {
    var resetToken: String
    var password: String
    var passwordConfirmation: String
}
