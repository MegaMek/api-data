//
//  BattleTechController.swift
//
//  Parent controller for BattleTech Endpoints
//  Author: Richard J Hancock
//  Date: 2024/02/12
//

import Vapor

extension BattleTech {
    struct RootController: RouteCollection {
        func boot(routes: any RoutesBuilder) throws {
            let battletech = routes.grouped("battletech")
            try battletech.register(collection: BattleTech.EraController())
            try battletech.register(collection: BattleTech.FactionController())
        }
    }
}
