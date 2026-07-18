//
//  ServersControllerTests.swift
//

import Fluent
import XCTVapor

@testable import App

final class ServersControllerTests: XCTestCase {
    var path = "/servers/announce"
    var app: Application!

    override func setUp() async throws {
        self.app = try await Application.make(.testing)
        try await configure(app)
        try await app.autoMigrate()
    }

    override func tearDown() async throws {
        try await app.autoRevert()
        try await self.app.asyncShutdown()
        self.app = nil
    }

    func testCreateWithNoKeyCreatesNewServer() async throws {
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

        try app.test(
            .POST, path,
            loggedInRequest: false,
            beforeRequest: { request in
                request.headers.replaceOrAdd(name: .xForwardedFor, value: "203.0.113.10")
                try request.content.encode(dto, as: .json)
            },
            afterResponse: { response in
                XCTAssertEqual(response.status, .ok)
                returnedKey = try response.content.decode(String.self)
                XCTAssertFalse(returnedKey.isEmpty)
            })

        let servers = try await MegaMek.Server.query(on: app.db).all()
        XCTAssertEqual(servers.count, 1)

        let server = try XCTUnwrap(servers.first)
        XCTAssertEqual(server.serverKey, returnedKey)
        XCTAssertEqual(server.ipAddress, "203.0.113.10")
        XCTAssertEqual(server.port, 2346)
        XCTAssertEqual(server.version, "0.50.1")
        XCTAssertEqual(server.phase, "lobby")
        XCTAssertEqual(server.passworded, true)
        XCTAssertEqual(server.users, "Alice, Bob")
        XCTAssertEqual(server.motd, "Welcome!")
    }

    func testCreateWithUnknownKeyCreatesNewServer() async throws {
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

        try app.test(
            .POST, path,
            loggedInRequest: false,
            beforeRequest: { request in
                request.headers.replaceOrAdd(name: .xForwardedFor, value: "203.0.113.11")
                try request.content.encode(dto, as: .json)
            },
            afterResponse: { response in
                XCTAssertEqual(response.status, .ok)
                returnedKey = try response.content.decode(String.self)
            })

        XCTAssertNotEqual(returnedKey, "does-not-exist")

        let servers = try await MegaMek.Server.query(on: app.db).all()
        XCTAssertEqual(servers.count, 1)

        let server = try XCTUnwrap(servers.first)
        XCTAssertEqual(server.passworded, false)
        XCTAssertEqual(server.phase, "")
        XCTAssertNil(server.motd)
    }

    func testCreateWithExistingKeyUpdatesServer() async throws {
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

        try app.test(
            .POST, path,
            loggedInRequest: false,
            beforeRequest: { request in
                request.headers.replaceOrAdd(name: .xForwardedFor, value: "203.0.113.12")
                try request.content.encode(dto, as: .json)
            },
            afterResponse: { response in
                XCTAssertEqual(response.status, .ok)
                returnedKey = try response.content.decode(String.self)
            })

        XCTAssertEqual(returnedKey, existing.serverKey)

        let servers = try await MegaMek.Server.query(on: app.db).all()
        XCTAssertEqual(servers.count, 1)

        let fetchedServer = try await MegaMek.Server.find(existing.id, on: app.db)
        let updated = try XCTUnwrap(fetchedServer)
        XCTAssertEqual(updated.ipAddress, "203.0.113.12")
        XCTAssertEqual(updated.port, 2347)
        XCTAssertEqual(updated.version, "0.50.1")
        XCTAssertEqual(updated.phase, "in_progress")
        XCTAssertEqual(updated.passworded, true)
        XCTAssertEqual(updated.users, "NewUser1, NewUser2")
        XCTAssertEqual(updated.motd, "Updated MOTD")
    }

    func testCreateWithoutClientIPReturnsBadRequest() async throws {
        let dto = MegaMek.ServerDTO(
            port: 2346,
            version: "0.50.1",
            phase: nil,
            passworded: nil,
            users: [],
            motd: nil,
            key: nil
        )

        try app.test(
            .POST, path,
            loggedInRequest: false,
            beforeRequest: { request in
                try request.content.encode(dto, as: .json)
            },
            afterResponse: { response in
                XCTAssertEqual(response.status, .badRequest)
            })
    }
}
