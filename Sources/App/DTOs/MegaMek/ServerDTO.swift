//
//  ServerDTO.swift
//  mul-api
//
//  Created by Richard Hancock on 12/29/25.
//

/// DTO (Data Transfer Object) for a MegaMek client's server-announcement request — the JSON
/// body a running MegaMek game server POSTs to this API to advertise itself, decoded by
/// `ServersController.create(_:)` into a ``MegaMek/Server`` database record.

extension MegaMek {
    /// The wire shape of an incoming server announcement. Deliberately shaped differently
    /// from ``MegaMek/Server``: `users` arrives as an array here (joined into a single
    /// comma-separated string on the model), several fields are optional here but required
    /// or defaulted on the model, and `key` — when present — is the `serverKey` from a
    /// previous announcement, letting the controller update that existing record instead of
    /// creating a duplicate one; `ipAddress` isn't part of this DTO at all since it's taken
    /// from the request's actual peer address rather than trusted from client input.
    struct ServerDTO : Codable {
        var port: Int
        var version: String
        var phase: String?
        var passworded: Bool?
        var users: [String]
        var motd: String?
        var key: String?
    }
}
