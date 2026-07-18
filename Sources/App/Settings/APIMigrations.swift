///  Migrations.swift
///
///  The definitive, ordered list of every Fluent migration applied to this app's database
///  at startup — the "table of contents" for how the schema has evolved over time and in
///  what order. Each `app.migrations.add(...)` call below registers one migration type
///  (see the individual files, e.g. under `Migrations/Security/` and `Migrations/MegaMek/`,
///  each named with a date prefix such as `2022-12-27-CreateUser.swift`). Vapor/Fluent runs
///  registered migrations in this list's order and records which have already run, so:
///  - New migrations must be appended, never inserted earlier in the list.
///  - The order here should track the chronological order of the migrations' date
///    prefixes, since a later migration may depend on a table/column an earlier one
///    created.
//
//  All Migrations for the app.
//
//  Created by Richard Hancock on 2024/02/12
//

import Fluent
import QueuesFluentDriver
import Vapor

/// Namespace holding the app's migration-registration logic.
struct APIMigrations {
    /// Registers every migration this app knows about with Vapor, in the order they must
    /// run to reproduce the current schema from scratch.
    /// - Parameter app: The Vapor `Application` whose `app.migrations` registry is populated.
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

        // MegaMek
        app.migrations.add(MegaMek.CreateServer())

        // Fixes
        app.migrations.add(BattleTech.FixAmmoAeroUseColumnName())
    }
}
