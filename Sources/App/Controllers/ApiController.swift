//
//  ApiController.swift
//  mul-api
//
//  Created by Richard Hancock on 5/9/25.
//

/// Root of the versioned `/api` route namespace. Registered from `routes.swift`,
/// this mounts the `/api/v1/...` surface used for the newer, versioned parts of
/// the API (currently the servers-announce endpoints), as opposed to the
/// unversioned `/battletech/...` data endpoints.
import Vapor

/// Empty namespace type. `Api.V1`, `Api.RootController`, etc. are declared as
/// nested types in extensions of ``Api``, purely to group the versioned-API types
/// under one name.
struct Api {}

extension Api {
    /// A Vapor `RouteCollection` — a type that groups a set of related HTTP routes
    /// and registers them on the app's router via `boot(routes:)`. This is the
    /// entry point for everything under `/api`.
    struct RootController: RouteCollection {
        /// Groups all routes under the `/api` path prefix and mounts the `v1`
        /// route collection beneath it, producing paths like `/api/v1/servers`.
        ///
        /// - Parameter routes: The `RoutesBuilder` (the app's router, or a group
        ///   of it) to register routes on.
        /// - Throws: Rethrows any error from registering the `v1` collection.
        func boot(routes: any RoutesBuilder) throws {
            let api = routes.grouped("api")
            try api.register(collection: Api.V1.RootController())
        }
    }
}
