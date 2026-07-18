//
//  User+Helpers.swift
//
//
//  Created by Richard Hancock on 4/2/23.
//

/// Role/permission-checking helpers and a uniqueness guard on ``Security/User``. These
/// convenience methods translate the raw ``Security/UserRole`` into the yes/no questions
/// call sites actually need (is this account active, does it have at least this privilege
/// level, etc.) instead of switching on the role everywhere.

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
    /// Whether the account is usable for authentication — `false` for banned, deactivated,
    /// or not-yet-confirmed accounts, `true` for every other role.
    /// - Returns: `true` if the user is allowed to log in / act.
    func active() -> Bool {
        switch self.role {
        case .banned, .deactivated, .nonConfirmed:
            return false
        default:
            return true
        }
    }

    /// Checks that no other user already has this user's `username` or `email`, throwing a
    /// conflict error if one does. Intended to be called before creating/updating a user.
    /// - Parameter req: The current request, used for database access.
    /// - Throws: `Abort(.conflict)` if the username or email is already taken.
    func ensureUnique(_ req: Request) async throws {
        guard
            try await Security.User.query(on: req.db)
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

    /// Whether the role grants at least subscriber-level privileges (subscriber and above).
    /// - Returns: `true` if the role is `.subscriber` or higher.
    func isSubscriber() -> Bool {
        switch self.role {
        case .subscriber, .demoAgent, .contentManagement, .developer, .administrator,
            .superAdministrator:
            return true
        default:
            return false
        }
    }

    /// Whether the role grants at least demo-agent-level privileges (demo agent and above).
    /// - Returns: `true` if the role is `.demoAgent` or higher.
    func isDemoAgent() -> Bool {
        switch self.role {
        case .demoAgent, .contentManagement, .developer, .administrator, .superAdministrator:
            return true
        default:
            return false
        }
    }

    /// Whether the role grants at least content-management-level privileges.
    /// - Returns: `true` if the role is `.contentManagement` or higher.
    func isContentManagement() -> Bool {
        switch self.role {
        case .contentManagement, .developer, .administrator, .superAdministrator:
            return true
        default:
            return false
        }
    }

    /// Whether the role grants at least developer-level privileges.
    /// - Returns: `true` if the role is `.developer` or higher.
    func isDeveloper() -> Bool {
        switch self.role {
        case .developer, .administrator, .superAdministrator:
            return true
        default:
            return false
        }
    }

    /// Whether the role grants administrator-level privileges.
    /// - Returns: `true` if the role is `.administrator` or `.superAdministrator`.
    func isAdministrator() -> Bool {
        switch self.role {
        case .administrator, .superAdministrator:
            return true
        default:
            return false
        }
    }
}
