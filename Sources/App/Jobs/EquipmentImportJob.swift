//
//  EquipmentImportJob.swift
//
//
//  Created by Richard Hancock on 4/6/24.
//

import Foundation
import Queues
import Vapor

struct EquipmentImportJob: AsyncJob {
  typealias Payload = Importers.EquipmentCSVRow

  func dequeue(_ context: QueueContext, _ payload: Importers.EquipmentCSVRow) async throws {
    _ = try await BattleTech.Equipment.findOrCreate(
      csvRow: payload,
      on: context.application.db(.primary)
    )
  }

  public func nextRetryIn(attempt: Int) -> Int {
    return Int.random(in: 15...60)
  }

}
