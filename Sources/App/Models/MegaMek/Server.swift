//
//  Server.swift
//  mul-api
//
//  Created by Richard Hancock on 5/9/25.
//

import Fluent
import Vapor

extension MegaMek {
    final class Server: Model, Content, @unchecked Sendable {
        public static let schema: String = MegaMek.Server.V20250509.schemaName
        public static let space: String? = MegaMek.Server.V20250509.spaceName

        @ID
        var id: UUID?

        @Field(key: MegaMek.Server.V20250509.port)
        var port: Int

        @Field(key: MegaMek.Server.V20250509.ipAddress)
        var ipAddress: String

        @Field(key: MegaMek.Server.V20250509.passworded)
        var passworded: Bool

        @Field(key: MegaMek.Server.V20250509.users)
        var users: String

        @Field(key: MegaMek.Server.V20250509.serverKey)
        var serverKey: String

        @Field(key: MegaMek.Server.V20250509.version)
        var version: String

        @Field(key: MegaMek.Server.V20250509.phase)
        var phase: String

        @OptionalField(key: MegaMek.Server.V20250509.motd)
        var motd: String?

        @Timestamp(key: MegaMek.Server.V20250509.createdAt, on: .create)
        var createdAt: Date?

        @Timestamp(key: MegaMek.Server.V20250509.updatedAt, on: .update)
        var updatedAt: Date?

        init() {}

        init(
            id: UUID? = nil,
            port: Int = 2346,
            ipAddress: String,
            passworded: Bool = false,
            users: String = "",
            version: String,
            phase: String,
            motd: String? = nil
        ) {
            self.id = id
            self.port = port
            self.ipAddress = ipAddress
            self.passworded = passworded
            self.users = users
            self.version = version
            self.phase = phase
            self.motd = motd

            self.serverKey = [UInt8].random(count: 16).base64.base64URLSafe()
        }
    }
}
