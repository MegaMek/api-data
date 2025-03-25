//
//  WeaponImportJob.swift
//
//
//  Created by Richard Hancock on 4/6/24.
//

import Foundation
import Queues
import Vapor

struct WeaponImportJob: AsyncJob {
    typealias Payload = Importers.WeaponCSVRow

    func dequeue(_ context: QueueContext, _ payload: Importers.WeaponCSVRow) async throws {
        _ = try await BattleTech.Weapon.findOrCreate(
            csvRow: payload,
            on: context.application.db(.primary)
        )
    }

    public func nextRetryIn(attempt: Int) -> Int {
        return Int.random(in: 15...60)
    }
}
