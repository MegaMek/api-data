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
