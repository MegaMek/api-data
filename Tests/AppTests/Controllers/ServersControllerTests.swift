//
//  ServersControllerTests.swift
//

import Fluent
import Testing
import VaporTesting

@testable import App

@Suite(.serialized, .databaseSerialized)
struct ServersControllerTests {
    let path = "/servers/announce"

    @Test
    func createWithNoKeyCreatesNewServer() async throws {
        try await withTestApp { app in
            let dto = MegaMek.ServerDTO(
                port: 2346,
                version: "0.50.1",
                phase: "lobby",
                passworded: true,
                users: ["Alice", "Bob"],
                motd: "Welcome!",
                key: nil
            )

            var returnedKey = ""

            try await app.test(
                .POST, path,
                loggedInRequest: false,
                beforeRequest: { request in
                    request.headers.replaceOrAdd(name: .xForwardedFor, value: "203.0.113.10")
                    try request.content.encode(dto, as: .json)
                },
                afterResponse: { response in
                    #expect(response.status == .ok)
                    returnedKey = try response.content.decode(String.self)
                    #expect(!returnedKey.isEmpty)
                })

            let servers = try await MegaMek.Server.query(on: app.db).all()
            #expect(servers.count == 1)

            let server = try #require(servers.first)
            #expect(server.serverKey == returnedKey)
            #expect(server.ipAddress == "203.0.113.10")
            #expect(server.port == 2346)
            #expect(server.version == "0.50.1")
            #expect(server.phase == "lobby")
            #expect(server.passworded == true)
            #expect(server.users == "Alice, Bob")
            #expect(server.motd == "Welcome!")
        }
    }

    @Test
    func createWithUnknownKeyCreatesNewServer() async throws {
        try await withTestApp { app in
            let dto = MegaMek.ServerDTO(
                port: 2346,
                version: "0.50.1",
                phase: nil,
                passworded: nil,
                users: [],
                motd: nil,
                key: "does-not-exist"
            )

            var returnedKey = ""

            try await app.test(
                .POST, path,
                loggedInRequest: false,
                beforeRequest: { request in
                    request.headers.replaceOrAdd(name: .xForwardedFor, value: "203.0.113.11")
                    try request.content.encode(dto, as: .json)
                },
                afterResponse: { response in
                    #expect(response.status == .ok)
                    returnedKey = try response.content.decode(String.self)
                })

            #expect(returnedKey != "does-not-exist")

            let servers = try await MegaMek.Server.query(on: app.db).all()
            #expect(servers.count == 1)

            let server = try #require(servers.first)
            #expect(server.passworded == false)
            #expect(server.phase == "")
            #expect(server.motd == nil)
        }
    }

    @Test
    func createWithExistingKeyUpdatesServer() async throws {
        try await withTestApp { app in
            let existing = try await MegaMek.Server.create(
                port: 2346,
                ipAddress: "198.51.100.1",
                passworded: false,
                users: "OldUser",
                version: "0.49.0",
                phase: "lobby",
                motd: nil,
                on: app.db)

            let dto = MegaMek.ServerDTO(
                port: 2347,
                version: "0.50.1",
                phase: "in_progress",
                passworded: true,
                users: ["NewUser1", "NewUser2"],
                motd: "Updated MOTD",
                key: existing.serverKey
            )

            var returnedKey = ""

            try await app.test(
                .POST, path,
                loggedInRequest: false,
                beforeRequest: { request in
                    request.headers.replaceOrAdd(name: .xForwardedFor, value: "203.0.113.12")
                    try request.content.encode(dto, as: .json)
                },
                afterResponse: { response in
                    #expect(response.status == .ok)
                    returnedKey = try response.content.decode(String.self)
                })

            #expect(returnedKey == existing.serverKey)

            let servers = try await MegaMek.Server.query(on: app.db).all()
            #expect(servers.count == 1)

            let fetchedServer = try await MegaMek.Server.find(existing.id, on: app.db)
            let updated = try #require(fetchedServer)
            #expect(updated.ipAddress == "203.0.113.12")
            #expect(updated.port == 2347)
            #expect(updated.version == "0.50.1")
            #expect(updated.phase == "in_progress")
            #expect(updated.passworded == true)
            #expect(updated.users == "NewUser1, NewUser2")
            #expect(updated.motd == "Updated MOTD")
        }
    }

    @Test
    func createWithoutClientIPReturnsBadRequest() async throws {
        try await withTestApp { app in
            let dto = MegaMek.ServerDTO(
                port: 2346,
                version: "0.50.1",
                phase: nil,
                passworded: nil,
                users: [],
                motd: nil,
                key: nil
            )

            try await app.test(
                .POST, path,
                loggedInRequest: false,
                beforeRequest: { request in
                    try request.content.encode(dto, as: .json)
                },
                afterResponse: { response in
                    #expect(response.status == .badRequest)
                })
        }
    }
}
