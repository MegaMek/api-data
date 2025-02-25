//
//  JobSchedules.swift
//  FASAAPI
//
//  Created by Richard Hancock on 2/18/25.
//

import QueuesFluentDriver
import Vapor

struct JobSchedules {
    static func setupQueues(_ app: Application) async throws {
        app.queues.use(.fluent())
        app.queues.configuration.workerCount = 1
        app.queues.configuration.refreshInterval = .seconds(5)
    }

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
