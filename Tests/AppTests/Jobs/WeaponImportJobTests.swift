//
//  WeaponImportJobTests.swift
//
//  Created by Richard Hancock on 2024-02-22.
//

import Fluent
import Queues
import Testing
import VaporTesting

@testable import App

@Suite(.serialized, .databaseSerialized)
struct WeaponImportJobTests {
    @Test
    func weaponJob() async throws {
        try await withTestApp { app in
            let job = WeaponImportJob()
            let context = QueueContext(
                queueName: .init(string: "test"), configuration: .init(), application: app,
                logger: app.logger, on: app.eventLoopGroup.any())
            let csvRow = Importers.WeaponCSVRow(row: data())
            try await job.dequeue(context, csvRow)
            let count = try await BattleTech.Weapon.query(on: app.db).count()
            #expect(count == 1)
        }
    }

    @Test
    func weaponJobDuplicateRun() async throws {
        try await withTestApp { app in
            let job = WeaponImportJob()
            let context = QueueContext(
                queueName: .init(string: "test"), configuration: .init(), application: app,
                logger: app.logger, on: app.eventLoopGroup.any())
            let csvRow = Importers.WeaponCSVRow(row: data())
            try await job.dequeue(context, csvRow)
            try await job.dequeue(context, csvRow)
            let count = try await BattleTech.Weapon.query(on: app.db).count()
            #expect(count == 1)
        }
    }

    private func data() -> [String] {
        [
            "Bombast Laser",
            "Inner Sphere",
            "IS_Advanced/IS_Experimental",
            "D/X-X-E-E",
            "Advanced",
            "3064(LC)",
            "3064(LC)",
            "3085(LC)",
            "-",
            "-",
            "-",
            "7.0",
            "3",
            "200000.0",
            "137.0",
            "319, TO",
            "-1",
            "5",
            "10",
            "15",
            "20",
            "3",
            "6",
            "9",
            "12",
            "12",
            "12",
            "12",
            "12",
            "12",
            "Bombast Laser,IS Bombast Laser,ISBombastLaser,",

        ]
    }
}
