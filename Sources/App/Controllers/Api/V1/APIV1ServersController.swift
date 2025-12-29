//
//  APIV1ServersController.swift
//  mul-api
//
//  Created by Richard Hancock on 5/9/25.
//

import Vapor

extension Api.V1 {
    struct ServersController: RouteCollection {
        func boot(routes: any RoutesBuilder) throws {
            let servers = routes.grouped("servers")
            servers.get(use: index).description("Get A List Of Servers")
            servers.post(use: create).description("Add A Server To The List")
            servers.put(":server_id", use: update).description("Update an existing server")
            servers.patch(":server_id", use: update).description("Update an existing server")
            servers.delete(":server_id", use: destroy).description("Delete an existing server.")
        }

        func index(req: Request) async throws -> [MegaMek.Server] {
            return try await MegaMek.Server.query(on: req.db).all()
        }

        func create(req: Request) async throws -> Response {
            return .init(status: .accepted)
        }

        func update(req: Request) async throws -> Response {
            return .init(status: .accepted)
        }

        func destroy(req: Request) async throws -> Response {
            return .init(status: .accepted)
        }
    }
}
