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

    try await JobSchedules.setupQueues(app)
    try await JobSchedules.scheduleJobs(app)

    app.views.use(.leaf)

    // register routes
    try routes(app)
}
