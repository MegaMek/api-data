//
//  AmmoImportJob.swift
//
//
//  Created by Richard Hancock on 4/6/24.
//

import Foundation
import Queues
import Vapor

struct AmmoImportJob: AsyncJob {
    typealias Payload = Importers.AmmoCSVRow

    func dequeue(_ context: QueueContext, _ payload: Importers.AmmoCSVRow) async throws {
        _ = try await BattleTech.Ammo.findOrCreate(
            csvRow: payload,
            on: context.application.db
        )
    }

    public func nextRetryIn(attempt: Int) -> Int {
        return Int.random(in: 15...60)
    }
}
