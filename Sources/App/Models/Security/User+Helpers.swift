//
//  File.swift
//
//
//  Created by Richard Hancock on 4/2/23.
//

import Fluent
import Vapor

///    case deactivated
///    case nonConfirmed = "non_confirmed"
///    case banned
///    case guest
///    case registered
///    case subscriber
///    case demoAgent = "demo_agent"
///    case contentManagement = "content_management"
///    case developer
///    case administrator
///    case superAdministrator = "super_administrator"

extension Security.User {
    func active() -> Bool {
        switch self.role {
            case .banned, .deactivated, .nonConfirmed:
                return false
            default:
                return true
        }
    }

    func ensureUnique(_ req: Request) async throws {
        guard
            try await Security.User.query(on: req.db(.replica))
                .group(
                    .or,
                    { group in
                        group.filter(\.$username == self.username)
                            .filter(\.$email == self.email)
                    }
                ).count() == 0
        else {
            throw Abort(.conflict, reason: "Username or Email already Taken")
        }
    }

    func isSubscriber() -> Bool {
        switch self.role {
            case .subscriber, .demoAgent, .contentManagement, .developer, .administrator,
                    .superAdministrator:
                return true
            default:
                return false
        }
    }

    func isDemoAgent() -> Bool {
        switch self.role {
            case .demoAgent, .contentManagement, .developer, .administrator, .superAdministrator:
                return true
            default:
                return false
        }
    }

    func isContentManagement() -> Bool {
        switch self.role {
            case .contentManagement, .developer, .administrator, .superAdministrator:
                return true
            default:
                return false
        }
    }

    func isDeveloper() -> Bool {
        switch self.role {
            case .developer, .administrator, .superAdministrator:
                return true
            default:
                return false
        }
    }

    func isAdministrator() -> Bool {
        switch self.role {
            case .administrator, .superAdministrator:
                return true
            default:
                return false
        }
    }
}
