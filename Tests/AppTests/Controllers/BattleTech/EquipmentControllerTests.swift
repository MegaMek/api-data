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
struct EquipmentControllerTests {
    let path = "/battletech/equipment"

    @Test
    func index() async throws {
        try await withTestApp { app in
            _ = try await BattleTech.Equipment.create(on: app.db)
            let equipmentCount = try await BattleTech.Equipment.query(on: app.db).count()

            try await app.test(
                .GET, path,
                loggedInRequest: false,
                afterResponse: { response in
                    let equipment = try response.content.decode(Page<BattleTech.Equipment>.self)
                    #expect(equipment.metadata.total == equipmentCount)
                })
        }
    }

    @Test
    func show() async throws {
        try await withTestApp { app in
            let equipment = try await BattleTech.Equipment.create(on: app.db)
            let showPath = "\(path)/\(equipment.id!)"

            try await app.test(
                .GET, showPath,
                loggedInRequest: false,
                afterResponse: { response in
                    let returnedEquipment = try response.content.decode(BattleTech.Equipment.self)
                    #expect(equipment.name == returnedEquipment.name)
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
            let equipment = try await BattleTech.Equipment.create(on: app.db)
            let showPath = "\(path)/\(equipment.id!)"

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
            let testFileByteBuffer = try await TestResources.buffer(for: "BattleTech/misc.csv")
            let equipmentMassImport = EquipmentMassImport(
                file: File(data: testFileByteBuffer, filename: "misc.csv"))

            let massImportPath = "\(path)/import"

            try await app.test(
                .POST, massImportPath,
                loggedInRequest: false,
                beforeRequest: { request in
                    try request.content.encode(equipmentMassImport)
                },
                afterResponse: { response in
                    #expect(response.status == .created)
                    #expect(app.queues.queue.pop() != nil)
                })
        }
    }
}
