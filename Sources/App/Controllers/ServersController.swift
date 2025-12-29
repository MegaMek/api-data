//
//  ServersController.swift
//  mul-api
//
//  Created by Richard Hancock on 12/29/25.
//
// Only here to support transition to new API system for Announcement system

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
        return "Temp"
    }
}
