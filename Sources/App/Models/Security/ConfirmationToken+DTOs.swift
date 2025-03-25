//
//  ConfirmationTokenDTOs.swift
//
//  DTOs related to Confirmation Token
//
//  Created by Richard Hancock on 4/2/23.
//

import Vapor

struct ConfirmUserDTO: Codable, Content {
    var confirmToken: String
}
