//
//  Role.swift
//
//  User Role
//
//  Created by Richard Hancock on 12/27/22.
//

/// Defines ``Security/UserRole``, the permission-level enum stored on every ``Security/User``.

import Vapor

extension Security {
    /// The permission/status level of a ``Security/User``, roughly ordered from least to
    /// most privileged, plus special statuses (`deactivated`, `nonConfirmed`, `banned`) that
    /// mark an account as not currently active. Conforms to `Content` so it can be
    /// encoded/decoded directly as JSON, and `CaseIterable` for enumerating valid roles.
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

        /// Manually overrides the compiler-synthesized `CaseIterable.allCases` to control
        /// ordering and to deliberately omit `.superAdministrator` (that role is not meant
        /// to be assignable/listed through normal role-management UI or API surfaces). Holds
        /// the roles considered selectable/listable, in display order.
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
