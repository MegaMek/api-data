/// Top-level route registration for the app. Called once from `configure(_:)` during
/// startup, after the database, migrations, and job queues are set up. Mounts each
/// top-level `RouteCollection` (a type that groups related HTTP routes and knows how
/// to register itself on a Vapor `Application`) onto the app's router.
import Fluent
import Vapor

/// Registers every top-level route group exposed by the API.
///
/// Mounts:
/// - ``Api/RootController`` for the versioned `/api/v1/...` surface.
/// - ``BattleTech/RootController`` for the public `/battletech/...` data endpoints
///   (weapons, equipment, ammo, factions, eras, rules, tech levels/bases).
/// - ``ServersController`` for the legacy top-level `/servers` endpoints used by
///   MegaMek clients to announce themselves, kept during the transition to the
///   versioned API.
///
/// - Parameter app: The Vapor `Application` being configured.
/// - Throws: Rethrows any error raised while a controller registers its routes.
func routes(_ app: Application) throws {
    try app.register(collection: Api.RootController())
    try app.register(collection: BattleTech.RootController())
    try app.register(collection: ServersController())
}
