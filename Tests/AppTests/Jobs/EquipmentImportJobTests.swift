//
//  EquipmentImportJobTests.swift
//
//  Created by Richard Hancock on 2024-02-22.
//

import Fluent
import Queues
import XCTVapor

@testable import App

final class EquipmentImportJobTests: XCTestCase {
    func testEquipmentJob() async throws {
        let app = Application(.testing)
        defer { app.shutdown() }
        try await configureApp(app)

        let job = EquipmentImportJob()
        let context = QueueContext(
            queueName: .init(string: "test"), configuration: .init(), application: app,
            logger: app.logger, on: app.eventLoopGroup.any())
        let csvRow = Importers.EquipmentCSVRow(row: data())
        try await job.dequeue(context, csvRow)
        let count = try await BattleTech.Equipment.query(on: app.db).count()
        XCTAssertEqual(count, 1)
    }

    func testEquipmentJobDuplicateRun() async throws {
        let app = Application(.testing)
        defer { app.shutdown() }
        try await configureApp(app)

        let job = EquipmentImportJob()
        let context = QueueContext(
            queueName: .init(string: "test"), configuration: .init(), application: app,
            logger: app.logger, on: app.eventLoopGroup.any())
        let csvRow = Importers.EquipmentCSVRow(row: data())
        try await job.dequeue(context, csvRow)
        try await job.dequeue(context, csvRow)
        let count = try await BattleTech.Equipment.query(on: app.db).count()
        XCTAssertEqual(count, 1)
    }

    private func data() -> [String] {
        [
            "C3 Boosted System (Slave)",
            "Inner Sphere",
            "IS_Advanced/IS_Experimental",
            "E/X-X-F-E",
            "Advanced",
            "3073(FS)",
            "3073(FS)",
            "3100(FS)",
            "-",
            "-",
            "-",
            "3.0",
            "2",
            "500000.0",
            "0.0",
            "298, TO",
            "ISC3BoostedSystemSlaveUnit,IS C3 Boosted System Slave,C3 Boosted System (C3BS) [Slave],"
        ]
    }

    private func configureApp(_ app: Application) async throws {
        try await configure(app)
        try await app.autoRevert()
        try await app.autoMigrate()
    }
}
