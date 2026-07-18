//
//  APIV1Controller.swift
//  mul-api
//
//  Created by Richard Hancock on 5/9/25.
//

/// Root of the `/api/v1` route namespace, mounted by ``Api/RootController`` under
/// `/api`. Groups together the version-1 route collections; currently just the
/// servers-announce endpoints.
import Vapor

extension Api {
    /// Empty namespace type for version-1 API types (e.g. ``Api/V1/ServersController``),
    /// grouped under `Api.V1` purely to keep versioned types organized.
    struct V1 {}
}

extension Api.V1 {
    /// A Vapor `RouteCollection` for everything under `/api/v1`.
    struct RootController: RouteCollection {
        /// Groups all routes under the `/api/v1` path prefix and mounts the
        /// servers route collection beneath it, producing paths like
        /// `/api/v1/servers`.
        ///
        /// - Parameter routes: The `RoutesBuilder` to register routes on.
        /// - Throws: Rethrows any error from registering the servers collection.
        func boot(routes: any RoutesBuilder) throws {
            let v1 = routes.grouped("v1")
            try v1.register(collection: Api.V1.ServersController())
        }
    }
}
