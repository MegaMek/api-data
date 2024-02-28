import NIOSSL
import Fluent
import FluentPostgresDriver
import Leaf
import Vapor

// configures your application
public func configure(_ app: Application) async throws {
    // Set max upload file size as imports should not exceed this anyways
    app.routes.defaultMaxBodySize = "10mb"

    // Serve Public Files
    app.middleware.use(FileMiddleware(publicDirectory: app.directory.publicDirectory))

    // Database Configuration
    try await ConfigureDatabase.configure(app)

    APIMigrations.applyMigrations(app)

    app.views.use(.leaf)

    // register routes
    try routes(app)
}
