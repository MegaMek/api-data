//
//  AmmoImportJobTests.swift
//
//  Created by Richard Hancock on 2024-04-06.
//

import Fluent
import Queues
import Testing
import VaporTesting

@testable import App

@Suite(.serialized, .databaseSerialized)
struct AmmoImportJobTests {
    @Test
    func ammoJob() async throws {
        try await withTestApp { app in
            let job = AmmoImportJob()
            let context = QueueContext(
                queueName: .init(string: "test"), configuration: .init(), application: app,
                logger: app.logger, on: app.eventLoopGroup.any())
            let csvRow = Importers.AmmoCSVRow(row: data())
            try await job.dequeue(context, csvRow)
            let count = try await BattleTech.Ammo.query(on: app.db).count()
            #expect(count == 1)
        }
    }

    @Test
    func ammoJobDuplicateRun() async throws {
        try await withTestApp { app in
            let job = AmmoImportJob()
            let context = QueueContext(
                queueName: .init(string: "test"), configuration: .init(), application: app,
                logger: app.logger, on: app.eventLoopGroup.any())
            let csvRow = Importers.AmmoCSVRow(row: data())
            try await job.dequeue(context, csvRow)
            try await job.dequeue(context, csvRow)
            let count = try await BattleTech.Ammo.query(on: app.db).count()
            #expect(count == 1)
        }
    }

    private func data() -> [String] {
        [
            "HVAC/10 Ammo",
            "Inner Sphere",
            "IS_Advanced/IS_Experimental",
            "D/X-X-F-E",
            "Advanced",
            "3059(CC)",
            "3059(CC)",
            "3079(CC)",
            "-",
            "-",
            "-",
            "1.0",
            "1",
            "20000.0",
            "20.0",
            "285, TO",
            "FALSE",
            "[M_STANDARD]",
            "1",
            "10",
            "8",
            "0.0",
            "FALSE",
            "125.0",
            "TRUE",
            "IS Ammo HVAC/10,ISHVAC10 Ammo,IS Hyper Velocity Autocannon/10 Ammo,Hyper Velocity AC/10 Ammo,",
        ]
    }
}
