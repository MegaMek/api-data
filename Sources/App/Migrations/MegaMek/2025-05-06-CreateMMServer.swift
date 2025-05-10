//
//  2025-05-06-CreateMMServer.swift
//  mul-api
//
//  Created by Richard Hancock on 5/9/25.
//

import Fluent
import FluentSQL

extension MegaMek {
    struct CreateServer: AsyncMigration {
        func prepare(on database: any Database) async throws {
            try await database.schema(for: MegaMek.Server.self)
                .id()
                .field(MegaMek.Server.V20250509.port, .int, .required)
                .field(MegaMek.Server.V20250509.ipAddress, .string, .required)
                .field(MegaMek.Server.V20250509.passworded, .bool, .required)
                .field(MegaMek.Server.V20250509.users, .string, .required)
                .field(MegaMek.Server.V20250509.serverKey, .string, .required)
                .field(MegaMek.Server.V20250509.version, .string, .required)
                .field(MegaMek.Server.V20250509.phase, .string, .required)
                .field(MegaMek.Server.V20250509.motd, .string)
                .field(MegaMek.Server.V20250509.createdAt, .datetime)
                .field(MegaMek.Server.V20250509.updatedAt, .datetime)
                .unique(on: MegaMek.Server.V20250509.ipAddress, MegaMek.Server.V20250509.port)
                .unique(on: MegaMek.Server.V20250509.serverKey)
                .create()
        }

        func revert(on database: any Database) async throws {
            try await database.schema(for: MegaMek.Server.self).delete()
        }
    }
}

extension MegaMek.Server {
    enum V20250509 {
        static let schemaName = "servers"
        static let spaceName = "megamek"

        static let id = FieldKey(stringLiteral: "id")
        static let port = FieldKey(stringLiteral: "port")
        static let ipAddress = FieldKey(stringLiteral: "ip_address")
        static let passworded = FieldKey(stringLiteral: "passworded")
        static let users = FieldKey(stringLiteral: "users")
        static let serverKey = FieldKey(stringLiteral: "server_key")
        static let version = FieldKey(stringLiteral: "version")
        static let phase = FieldKey(stringLiteral: "phase")
        static let motd = FieldKey(stringLiteral: "motd")

        static let createdAt = FieldKey(stringLiteral: "created_at")
        static let updatedAt = FieldKey(stringLiteral: "updated_at")
    }
}
