//
//  JobSchedules.swift
//  FASAAPI
//
//  Created by Richard Hancock on 2/18/25.
//

import QueuesFluentDriver
import Vapor

/// Wires up Vapor's Queues package, which lets the app hand off slow work (like
/// importing thousands of CSV/XML rows) to background workers instead of blocking
/// an HTTP request. Jobs are dispatched with `req.queue.dispatch(_:_:)`, persisted
/// to the database via the Fluent queues driver, and later "dequeued" (executed) by
/// an in-process worker loop. Both functions here are called once from
/// ``configure(_:)`` during startup.
struct JobSchedules {
    /// Configures the queue driver and worker settings: uses the Fluent-backed
    /// queue storage (jobs persisted in the app's database), a single worker,
    /// and a 5-second polling interval for picking up newly dispatched jobs.
    ///
    /// - Parameter app: The `Application` to configure queues on.
    /// - Throws: Does not currently throw, but matches the async-throwing
    ///   configuration hooks used elsewhere in startup.
    static func setupQueues(_ app: Application) async throws {
        app.queues.use(.fluent())
        app.queues.configuration.workerCount = 1
        app.queues.configuration.refreshInterval = .seconds(5)
    }

    /// Registers every `Job` type the app knows how to run and starts the
    /// in-process worker and scheduler (skipped in the `.testing` environment so
    /// test runs don't spin up background workers).
    ///
    /// - Parameter app: The `Application` whose queues should be started.
    /// - Throws: Rethrows errors from starting the in-process job or scheduled-job
    ///   loops.
    static func scheduleJobs(_ app: Application) async throws {
        // Add Queuable Jobs
        app.queues.add(WeaponImportJob())
        app.queues.add(AmmoImportJob())
        app.queues.add(EquipmentImportJob())

        // Add Scheduled Jobs
        // app.queues.schedule(DeleteNonConfirmedUsersJob()).daily().at(.midnight)

        // Turn things on...
        if app.environment != .testing {
            try app.queues.startInProcessJobs(on: .default)
            try app.queues.startScheduledJobs()
        }
    }
}
