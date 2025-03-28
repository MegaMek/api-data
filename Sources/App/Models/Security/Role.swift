//
//  Role.swift
//
//  User Role
//
//  Created by Richard Hancock on 12/27/22.
//

import Vapor

extension Security {
    enum UserRole: String, Content, CaseIterable {
        case guest
        case registered
        case subscriber
        case demoAgent = "demo_agent"
        case contentManagement = "content_management"
        case developer
        case administrator
        case superAdministrator = "super_administrator"

        // added 4/2/23
        case deactivated
        case nonConfirmed = "non_confirmed"
        case banned

        static var allCases: [Security.UserRole] {
            [
                .banned,
                .deactivated,
                .guest,
                .nonConfirmed,
                .registered,
                .subscriber,
                .demoAgent,
                .contentManagement,
                .developer,
                .administrator,
            ]
        }
    }
}
