//
//  ServersController.swift
//  mul-api
//
//  Created by Richard Hancock on 12/29/25.
//
// Only here to support transition to new API system for Announcement system

import Fluent
import Vapor

struct ServersController: RouteCollection {
    func boot(routes: any RoutesBuilder) throws {
        let servers = routes.grouped("servers")
        servers.get(use: index).description("Get A List Of Servers")
        servers.post("announce", use: create).description("Add/Update A Server To The List")
    }

    func index(req: Request) async throws -> [MegaMek.Server] {
        return try await MegaMek.Server.query(on: req.db).all()
    }

    func create(req: Request) async throws -> String {
        let dto = try req.content.decode(MegaMek.ServerDTO.self)

        guard let ipAddress = req.peerAddress?.ipAddress else {
            throw Abort(.badRequest, reason: "Unable to determine client IP address")
        }

        let passworded = dto.passworded ?? false
        let users = dto.users.joined(separator: ", ")

        var existing: MegaMek.Server?
        if let key = dto.key {
            existing = try await MegaMek.Server.query(on: req.db)
                .filter(\.$serverKey == key)
                .first()
        }

        let server: MegaMek.Server
        if let existing {
            existing.ipAddress = ipAddress
            existing.port = dto.port
            existing.passworded = passworded
            existing.users = users
            existing.version = dto.version
            existing.phase = dto.phase ?? existing.phase
            existing.motd = dto.motd
            server = existing
        } else {
            server = MegaMek.Server(
                port: dto.port,
                ipAddress: ipAddress,
                passworded: passworded,
                users: users,
                version: dto.version,
                phase: dto.phase ?? "",
                motd: dto.motd
            )
        }

        try await server.save(on: req.db)

        return server.serverKey
    }
}
