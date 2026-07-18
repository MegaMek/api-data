//
//  BattleTechController.swift
//
//  Parent controller for BattleTech Endpoints
//  Author: Richard J Hancock
//  Date: 2024/02/12
//
/// Root of the public `/battletech` route namespace, registered from
/// `routes.swift`. This is the read-only BattleTech game-data API (weapons,
/// equipment, ammo, factions, eras, rules, tech levels/bases) sourced from the
/// MegaMek project.

import Vapor

extension BattleTech {
    /// A Vapor `RouteCollection` that mounts every BattleTech data sub-controller
    /// under `/battletech`.
    struct RootController: RouteCollection {
        /// Groups all routes under the `/battletech` path prefix and registers
        /// each domain sub-controller (ammo, equipment, eras, factions, munition
        /// types, rules, tech bases, tech levels, weapons) beneath it.
        ///
        /// - Parameter routes: The `RoutesBuilder` to register routes on.
        /// - Throws: Rethrows any error from registering a sub-controller.
        func boot(routes: any RoutesBuilder) throws {
            let battletech = routes.grouped("battletech")
            try battletech.register(collection: BattleTech.AmmoController())
            try battletech.register(collection: BattleTech.EquipmentController())
            try battletech.register(collection: BattleTech.EraController())
            try battletech.register(collection: BattleTech.FactionController())
            try battletech.register(collection: BattleTech.MunitionTypeController())
            try battletech.register(collection: BattleTech.RulesController())
            try battletech.register(collection: BattleTech.TechBaseController())
            try battletech.register(collection: BattleTech.TechLevelController())
            try battletech.register(collection: BattleTech.WeaponController())
        }
    }
}
