//
//  BattleTech.FactionsControllerTest.swift
//
//  Created by Richard Hancock on 2024-02-22.
//

import Fluent
import Testing
import VaporTesting

@testable import App

@Suite(.serialized, .databaseSerialized)
struct WeaponsControllerTests {
    let path = "/battletech/weapons"

    @Test
    func index() async throws {
        try await withTestApp { app in
            _ = try await BattleTech.Weapon.create(on: app.db)
            let weaponCount = try await BattleTech.Weapon.query(on: app.db).count()

            try await app.test(
                .GET, path,
                loggedInRequest: false,
                afterResponse: { response in
                    let weapons = try response.content.decode(Page<BattleTech.Weapon>.self)
                    #expect(weapons.metadata.total == weaponCount)
                })
        }
    }

    @Test
    func show() async throws {
        try await withTestApp { app in
            let weapon = try await BattleTech.Weapon.create(on: app.db)
            let showPath = "\(path)/\(weapon.id!)"

            try await app.test(
                .GET, showPath,
                loggedInRequest: false,
                afterResponse: { response in
                    let returnedWeapon = try response.content.decode(BattleTech.Weapon.self)
                    #expect(weapon.name == returnedWeapon.name)
                })
        }
    }

    @Test
    func showNotFound() async throws {
        try await withTestApp { app in
            let notFoundPath = "\(path)/NOT-A-UUID"

            try await app.test(
                .GET, notFoundPath,
                loggedInRequest: false,
                afterResponse: { response in
                    #expect(response.status == .notFound)
                })
        }
    }

    @Test
    func delete() async throws {
        try await withTestApp { app in
            let weapon = try await BattleTech.Weapon.create(on: app.db)
            let showPath = "\(path)/\(weapon.id!)"

            try await app.test(
                .DELETE, showPath,
                loggedInRequest: false,
                afterResponse: { response in
                    #expect(response.status == .noContent)
                })
        }
    }

    @Test
    func `import`() async throws {
        try await withTestApp { app in
            let testFileByteBuffer = try await TestResources.buffer(for: "BattleTech/weapons.csv")
            let weaponsMassImport = WeaponMassImport(
                file: File(data: testFileByteBuffer, filename: "weapons.csv"))

            let massImportPath = "\(path)/import"

            try await app.test(
                .POST, massImportPath,
                loggedInRequest: false,
                beforeRequest: { request in
                    try request.content.encode(weaponsMassImport)
                },
                afterResponse: { response in
                    #expect(response.status == .created)
                    #expect(app.queues.queue.pop() != nil)
                })
        }
    }
}
