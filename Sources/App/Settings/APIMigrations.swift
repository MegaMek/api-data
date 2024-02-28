//
//  Migrations.swift
//
//  All Migrations for the app.
//
//  Created by Richard Hancock on 2024/02/12
//

import Fluent
import Vapor

struct APIMigrations {
    static func applyMigrations(_ app: Application) {

        // Migrations
        app.migrations.add(BattleTech.CreateEras())
    }
}
