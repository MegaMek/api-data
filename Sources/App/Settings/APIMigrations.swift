//
//  Migrations.swift
//
//  All Migrations for the app.
//
//  Created by Richard Hancock on 2024/02/12
//

import Fluent
import QueuesFluentDriver
import Vapor

struct APIMigrations {
    static func applyMigrations(_ app: Application) {

        // Migrations
        app.migrations.add(BattleTech.CreateEras())
        app.migrations.add(BattleTech.CreateFactions())
        app.migrations.add(BattleTech.CreateFactionNames())
        app.migrations.add(BattleTech.CreateFactionSubfactionPivot())

        app.migrations.add(BattleTech.CreateRules())
        app.migrations.add(BattleTech.CreateTechBase())
        app.migrations.add(BattleTech.CreateTechLevel())
        app.migrations.add(BattleTech.CreateWeapons())
        app.migrations.add(BattleTech.CreateWeaponAlias())
        app.migrations.add(BattleTech.CreateRuleWeaponPivot())

        app.migrations.add(BattleTech.CreateMunitionType())
        app.migrations.add(BattleTech.CreateAmmo())
        app.migrations.add(BattleTech.CreateAmmoAlias())
        app.migrations.add(BattleTech.CreateAmmoRulePivot())

        app.migrations.add(BattleTech.CreateEquipment())
        app.migrations.add(BattleTech.CreateEquipmentAlias())
        app.migrations.add(BattleTech.CreateEquipmentRulePivot())

        app.migrations.add(BattleTech.AddStartYearToEras())
        app.migrations.add(BattleTech.AddImageToFactionName())

        // Security
        app.migrations.add(Security.CreateUser())
        app.migrations.add(Security.CreateToken())
        app.migrations.add(Security.CreateForgotPasswordToken())
        app.migrations.add(Security.CreateConfirmationToken())
        app.migrations.add(Security.AddConfirmedAtToUser())
        app.migrations.add(Security.AddFirstAndLastNameToUser())
        app.migrations.add(Security.AddUnconfirmedEmailToUser())

        // Queues
        app.migrations.add(JobModelMigration())

    }
}
