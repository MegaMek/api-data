//
//  APIV1Controller.swift
//  mul-api
//
//  Created by Richard Hancock on 5/9/25.
//

import Vapor

extension Api {
    struct V1 {}
}

extension Api.V1 {
    struct RootController: RouteCollection {
        func boot(routes: any RoutesBuilder) throws {
            let v1 = routes.grouped("v1")
            try v1.register(collection: Api.V1.ServersController())
        }
    }
}
