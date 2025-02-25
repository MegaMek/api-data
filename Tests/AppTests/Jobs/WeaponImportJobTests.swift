//
//  WeaponImportJobTests.swift
//
//  Created by Richard Hancock on 2024-02-22.
//

import Fluent
import Queues
import XCTVapor

@testable import App

final class WeaponImportJobTests: XCTestCase {
    func testWeaponJob() async throws {
        let app = Application(.testing)
        defer { app.shutdown() }
        try await configureApp(app)

        let job = WeaponImportJob()
        let context = QueueContext(
            queueName: .init(string: "test"), configuration: .init(), application: app,
            logger: app.logger, on: app.eventLoopGroup.any())
        let csvRow = Importers.WeaponCSVRow(row: data())
        try await job.dequeue(context, csvRow)
        let count = try await BattleTech.Weapon.query(on: app.db).count()
        XCTAssertEqual(count, 1)
    }

    func testWeaponJobDuplicateRun() async throws {
        let app = Application(.testing)
        defer { app.shutdown() }
        try await configureApp(app)

        let job = WeaponImportJob()
        let context = QueueContext(
            queueName: .init(string: "test"), configuration: .init(), application: app,
            logger: app.logger, on: app.eventLoopGroup.any())
        let csvRow = Importers.WeaponCSVRow(row: data())
        try await job.dequeue(context, csvRow)
        try await job.dequeue(context, csvRow)
        let count = try await BattleTech.Weapon.query(on: app.db).count()
        XCTAssertEqual(count, 1)
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
            "Bombast Laser,IS Bombast Laser,ISBombastLaser,"

        ]
    }

    private func configureApp(_ app: Application) async throws {
        try await configure(app)
        try await app.autoRevert()
        try await app.autoMigrate()
    }
}
