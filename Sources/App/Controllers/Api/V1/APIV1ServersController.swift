//
//  APIV1ServersController.swift
//  mul-api
//
//  Created by Richard Hancock on 5/9/25.
//

/// Versioned `/api/v1/servers` route collection: the planned replacement for the
/// legacy top-level `/servers` announce endpoints in ``ServersController``. Registered
/// under `/api/v1` by ``Api/V1/RootController``.
import Vapor

extension Api.V1 {
    /// A Vapor `RouteCollection` for the `/api/v1/servers` endpoints.
    ///
    /// - Note: The `create`, `update`, and `destroy` handlers are currently stubs
    ///   that always return `202 Accepted` without reading the request body or
    ///   touching the database — this collection is a scaffold for the API
    ///   migration in progress and is not yet functionally equivalent to the
    ///   legacy ``ServersController``.
    struct ServersController: RouteCollection {
        /// Groups routes under `/servers` (i.e. `/api/v1/servers`):
        /// `GET /` (list), `POST /` (create), `PUT`/`PATCH /:server_id` (update),
        /// and `DELETE /:server_id` (destroy).
        ///
        /// - Parameter routes: The `RoutesBuilder` to register routes on (already
        ///   scoped to `/api/v1` by the caller).
        /// - Throws: Does not currently throw; matches Vapor's `boot(routes:)`
        ///   signature.
        func boot(routes: any RoutesBuilder) throws {
            let servers = routes.grouped("servers")
            servers.get(use: index).description("Get A List Of Servers")
            servers.post(use: create).description("Add A Server To The List")
            servers.put(":server_id", use: update).description("Update an existing server")
            servers.patch(":server_id", use: update).description("Update an existing server")
            servers.delete(":server_id", use: destroy).description("Delete an existing server.")
        }

        /// Serves `GET /api/v1/servers`.
        ///
        /// - Parameter req: The incoming `Request`.
        /// - Returns: Every ``MegaMek/Server`` row currently in the database, as
        ///   JSON (unpaginated).
        /// - Throws: Rethrows errors from the database query.
        func index(req: Request) async throws -> [MegaMek.Server] {
            return try await MegaMek.Server.query(on: req.db).all()
        }

        /// Serves `POST /api/v1/servers`.
        ///
        /// - Parameter req: The incoming `Request` (currently unused).
        /// - Returns: A `202 Accepted` response. This is a placeholder — no server
        ///   is actually created yet.
        /// - Throws: Does not currently throw.
        func create(req: Request) async throws -> Response {
            return .init(status: .accepted)
        }

        /// Serves `PUT`/`PATCH /api/v1/servers/:server_id`.
        ///
        /// - Parameter req: The incoming `Request` (currently unused).
        /// - Returns: A `202 Accepted` response. This is a placeholder — no server
        ///   is actually updated yet.
        /// - Throws: Does not currently throw.
        func update(req: Request) async throws -> Response {
            return .init(status: .accepted)
        }

        /// Serves `DELETE /api/v1/servers/:server_id`.
        ///
        /// - Parameter req: The incoming `Request` (currently unused).
        /// - Returns: A `202 Accepted` response. This is a placeholder — no server
        ///   is actually deleted yet.
        /// - Throws: Does not currently throw.
        func destroy(req: Request) async throws -> Response {
            return .init(status: .accepted)
        }
    }
}
