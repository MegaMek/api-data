//
//  MegaMek+Testable Extension.swift
//
//  Extensions to MegaMek models for testing
//

import Fluent
import Vapor

@testable import App

extension MegaMek.Server {
    static func create(
        port: Int = 2346,
        ipAddress: String = "127.0.0.1",
        passworded: Bool = false,
        users: String = "",
        version: String = "0.50.0",
        phase: String = "lobby",
        motd: String? = nil,
        on database: any Database
    ) async throws -> MegaMek.Server {
        let server = MegaMek.Server(
            port: port,
            ipAddress: ipAddress,
            passworded: passworded,
            users: users,
            version: version,
            phase: phase,
            motd: motd
        )

        try await server.save(on: database)
        return server
    }
}
