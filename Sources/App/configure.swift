/// Application bootstrap: wires up the database, background job queues, view
/// rendering, and HTTP routes. Called once from ``Entrypoint/main()`` before the
/// server starts accepting requests.
import Fluent
import FluentPostgresDriver
import Leaf
import NIOSSL
import QueuesFluentDriver
import Vapor

/// Configures the Vapor `Application` for this service: sets request-body limits and
/// static file serving, connects to Postgres and applies Fluent migrations (via
/// ``ConfigureDatabase`` and `APIMigrations`), sets up and schedules the Queues-based
/// background jobs (via ``JobSchedules``), enables the Leaf templating engine (used to
/// render outgoing email bodies), and finally registers all HTTP routes.
///
/// - Parameter app: The `Application` instance to configure in place.
/// - Throws: Rethrows errors from database configuration, migrations, queue setup, or
///   route registration.
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
