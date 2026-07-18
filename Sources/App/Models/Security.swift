//
//  Security.swift
//
//
//  Created by Richard Hancock on 3/16/23.
//

/// Empty namespacing type for the app's authentication/authorization domain.
///
/// It has no members itself — its only purpose is to let related types be declared as
/// extensions on it (e.g. ``Security/User``, ``Security/Token``, ``Security/UserRole``) so
/// they are grouped under a common `Security.` prefix instead of polluting the global namespace.
struct Security {}
