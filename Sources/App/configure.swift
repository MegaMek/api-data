import Fluent
import FluentPostgresDriver
import Leaf
import NIOSSL
import QueuesFluentDriver
import Vapor

// configures your application
public func configure(_ app: Application) async throws {
    app.routes.defaultMaxBodySize = "10mb"
    app.middleware.use(FileMiddleware(publicDirectory: app.directory.publicDirectory))

    try await ConfigureDatabase.configure(app)
    APIMigrations.applyMigrations(app)

    app.views.use(.leaf)

    let weaponImportJob = WeaponImportJob()
    let ammoImportJob = AmmoImportJob()
    let equipmentImportJob = EquipmentImportJob()

    app.queues.add(weaponImportJob)
    app.queues.add(ammoImportJob)
    app.queues.add(equipmentImportJob)

    try app.queues.startInProcessJobs(on: .default)
    try app.queues.startScheduledJobs()

    // register routes
    try routes(app)
}
