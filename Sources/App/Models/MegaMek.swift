//
//  MegaMek.swift
//  mul-api
//
//  Created by Richard Hancock on 5/9/25.
//

/// Empty namespacing type for models related to MegaMek client/server installations that
/// announce themselves to this API (e.g. ``MegaMek/Server``, ``MegaMek/ServerDTO``).
///
/// Like ``Security``, it has no members of its own — it exists only so related types can be
/// written as `MegaMek.Server` etc. instead of living in the global namespace.
struct MegaMek {}
