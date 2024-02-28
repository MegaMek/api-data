//
//  ConfigureDatabase.swift
//
//  Code related to configuring the Primary and Replica Databases.
//  In order to fully work, the underling database must have full replication
//  enabled for all migrations to propagate.
//
//  Created by Richard Hancock on 2024/02/12.
//

import Fluent
import FluentPostgresDriver
import Vapor

struct ConfigureDatabase {
    static func configure(_ app: Application) async throws {
        let defaultPort = SQLPostgresConfiguration.ianaPortNumber

        let databaseHost = Environment.get("DATABASE_HOST") ?? "localhost"
        let databasePort = Environment.get("DATABASE_PORT").flatMap(Int.init(_:)) ?? defaultPort
        let databaseUsername = Environment.get("DATABASE_USERNAME") ?? "vapor"
        let databasePassword = Environment.get("DATABASE_PASSWORD") ?? "password"
        let databaseName = Environment.get("DATABASE_NAME") ?? "api-battletech"

        let replicaDatabaseHost = Environment.get("REPLICA_DATABASE_HOST") ?? databaseHost
        let replicaDatabasePort = Environment.get("REPLICA_DATABASE_PORT").flatMap(Int.init(_:)) ?? databasePort
        let replicaDatabaseUsername = Environment.get("REPLICA_DATABASE_USERNAME") ?? databaseUsername
        let replicaDatabasePassword = Environment.get("REPLICA_DATABASE_PASSWORD") ?? databasePassword
        let replicaDatabaseName = Environment.get("REPLICA_DATABASE_NAME") ?? databaseName

        app.databases.use(
            .postgres(
                configuration: SQLPostgresConfiguration(
                    hostname: databaseHost,
                    port: databasePort,
                    username: databaseUsername,
                    password: databasePassword,
                    database: databaseName,
                    tls: .prefer(try .init(configuration: .makeClientConfiguration()))
                ),
                connectionPoolTimeout: .seconds(30)
            ),
            as: .primary,
            isDefault: true)

        app.databases.use(
            .postgres(
                configuration: SQLPostgresConfiguration(
                    hostname: replicaDatabaseHost,
                    port: replicaDatabasePort,
                    username: replicaDatabaseUsername,
                    password: replicaDatabasePassword,
                    database: replicaDatabaseName,
                    tls: .prefer(try .init(configuration: .makeClientConfiguration()))
                ),
                connectionPoolTimeout: .seconds(30)
            ),
            as: .replica,
            isDefault: false)
    }
}

extension DatabaseID {
    static let primary = DatabaseID(string: "primary")
    static let replica = DatabaseID(string: "replica")
}
