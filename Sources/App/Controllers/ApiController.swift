//
//  ApiController.swift
//  mul-api
//
//  Created by Richard Hancock on 5/9/25.
//

import Vapor

struct Api {}

extension Api {
    struct RootController: RouteCollection {
        func boot(routes: any RoutesBuilder) throws {
            let api = routes.grouped("api")
            try api.register(collection: Api.V1.RootController())
        }
    }
}
