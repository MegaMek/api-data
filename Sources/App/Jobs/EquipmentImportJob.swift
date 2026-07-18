//
//  EquipmentImportJob.swift
//
//
//  Created by Richard Hancock on 4/6/24.
//

import Foundation
import Queues
import Vapor

/// A background `Job` (from Vapor's Queues package) that turns a single parsed
/// equipment CSV row into a database row. ``BattleTech/EquipmentController/massCreate(req:)``
/// dispatches one of these per row of an uploaded equipment CSV file rather than
/// writing rows synchronously; a worker (started by ``JobSchedules``) dequeues and
/// runs them.
struct EquipmentImportJob: AsyncJob {
    /// The data handed to this job when it is dispatched: one row of an equipment
    /// CSV file, already split into typed accessors.
    typealias Payload = Importers.EquipmentCSVRow

    /// Executes the job: finds an existing ``BattleTech/Equipment`` row matching
    /// the CSV row (by name) or creates a new one, then saves it.
    ///
    /// - Parameters:
    ///   - context: The `QueueContext` providing access to the application (and its
    ///     database) while the job runs.
    ///   - payload: The equipment CSV row to import.
    /// - Throws: Rethrows any error from finding/creating or saving the ``BattleTech/Equipment`` row.
    func dequeue(_ context: QueueContext, _ payload: Importers.EquipmentCSVRow) async throws {
        _ = try await BattleTech.Equipment.findOrCreate(
            csvRow: payload,
            on: context.application.db
        )
    }

    /// Determines the delay before retrying a failed job attempt.
    ///
    /// - Parameter attempt: The retry attempt number (unused; delay is randomized
    ///   regardless of attempt count).
    /// - Returns: A random delay between 15 and 60 seconds, to spread out retries
    ///   across a batch instead of retrying every failed row at once.
    public func nextRetryIn(attempt: Int) -> Int {
        return Int.random(in: 15...60)
    }

}
