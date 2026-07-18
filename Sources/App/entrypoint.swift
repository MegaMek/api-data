/// Main entrypoint for the service. Boots logging, builds the Vapor
/// `Application`, hands it to ``configure(_:)`` for setup, then runs the server
/// until shutdown.

import Logging
import NIOCore
import NIOPosix
import Vapor

/// The `@main` type for the executable; Swift calls ``main()`` to start the app.
@main
enum Entrypoint {
    /// Detects the runtime environment, bootstraps logging, creates the
    /// `Application`, runs ``configure(_:)``, then executes the app (serving
    /// requests) until it is asked to shut down.
    ///
    /// - Throws: Any error from environment detection, configuration, or running the
    ///   application; configuration errors are logged before being rethrown.
    static func main() async throws {
        var env = try Environment.detect()
        try LoggingSystem.bootstrap(from: &env)

        let app = try await Application.make(env)

        do {
            try await configure(app)
        } catch {
            app.logger.report(error: error)
            try? await app.asyncShutdown()
            throw error
        }
        try await app.execute()
        try await app.asyncShutdown()
    }
}
