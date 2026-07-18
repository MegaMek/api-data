/// Read-only public API for BattleTech munition types (e.g. Standard, Cluster,
/// Inferno ammo variants) and the ammo rows that use each type. Registered under
/// `/battletech/munition-types` by ``BattleTech/RootController``. There is no
/// import endpoint here — munition type rows are populated as a side effect of
/// the ammo CSV import (see ``AmmoImportJob``).
import Fluent
import Vapor
import XMLCoder

extension BattleTech {
    /// A Vapor `RouteCollection` for `/battletech/munition-types`.
    struct MunitionTypeController: RouteCollection {
        /// Groups routes under `/munition-types`: `GET /` (list), and
        /// `GET`/`DELETE /:munition_type_id` plus the nested
        /// `GET /:munition_type_id/ammo` listing.
        ///
        /// - Parameter routes: The `RoutesBuilder` to register routes on.
        /// - Throws: Does not currently throw; matches Vapor's `boot(routes:)`
        ///   signature.
        func boot(routes: RoutesBuilder) throws {
            let munitionTypes = routes.grouped("munition-types")
            munitionTypes.get(use: index).description("All Munition Types")

            munitionTypes.group(":munition_type_id") { munitionType in
                munitionType.get(use: show).description("Individual Munition Type")
                munitionType.delete(use: delete).description("Delete Munition Type")
                munitionType.get("ammo", use: ammo).description("Ammo for Munition Type")
            }

        }

        /// Serves `GET /battletech/munition-types`.
        ///
        /// - Parameter req: The incoming `Request`.
        /// - Returns: Every ``BattleTech/MunitionType`` row (unpaginated).
        /// - Throws: Rethrows errors from the database query.
        func index(req: Request) async throws -> [BattleTech.MunitionType] {
            try await BattleTech.MunitionType.query(on: req.db).all()
        }

        /// Serves `GET /battletech/munition-types/:munition_type_id`.
        ///
        /// - Parameter req: The incoming `Request`; must include a valid
        ///   `munition_type_id` UUID path parameter (read via `req.parameters`).
        /// - Returns: The matching ``BattleTech/MunitionType`` row.
        /// - Throws: `Abort(.notFound)` if the id is missing, not a UUID, or
        ///   doesn't match any row.
        func show(req: Request) async throws -> BattleTech.MunitionType {
            return try await getMunitionTypeForRequest(req: req)
        }

        /// Serves `DELETE /battletech/munition-types/:munition_type_id`.
        ///
        /// - Parameter req: The incoming `Request`; must include a valid
        ///   `munition_type_id` UUID path parameter.
        /// - Returns: `204 No Content` on success.
        /// - Throws: `Abort(.notFound)` if the munition type doesn't exist;
        ///   rethrows database errors otherwise.
        func delete(req: Request) async throws -> HTTPStatus {
            let munitionType = try await getMunitionTypeForRequest(req: req)
            try await munitionType.delete(on: req.db)
            return .noContent
        }

        /// Serves `GET /battletech/munition-types/:munition_type_id/ammo`.
        ///
        /// - Parameter req: The incoming `Request`; must include a valid
        ///   `munition_type_id` UUID path parameter, and honors pagination
        ///   query params (`page`, `per`).
        /// - Returns: A `Page` of ``BattleTech/Ammo`` rows that use this
        ///   munition type, via the model's `$ammo` relation.
        /// - Throws: `Abort(.notFound)` if the munition type doesn't exist;
        ///   rethrows database errors otherwise.
        func ammo(req: Request) async throws -> Page<BattleTech.Ammo> {
            let rule = try await getMunitionTypeForRequest(req: req)
            return try await rule.$ammo.query(on: req.db).paginate(for: req)
        }

        /// Looks up the ``BattleTech/MunitionType`` row identified by the
        /// `munition_type_id` path parameter.
        ///
        /// - Parameter req: The incoming `Request` supplying the
        ///   `munition_type_id` path parameter.
        /// - Returns: The matching munition type row.
        /// - Throws: `Abort(.notFound)` if the id is missing, not a UUID, or
        ///   doesn't match any row.
        private func getMunitionTypeForRequest(req: Request) async throws -> BattleTech.MunitionType
        {
            guard let idString = req.parameters.get("munition_type_id"),
                let munitionTypeUUID = UUID(idString),
                let munitionType = try await BattleTech.MunitionType.query(on: req.db)
                    .filter(\.$id == munitionTypeUUID)
                    .first()
            else {
                throw Abort(.notFound)
            }

            return munitionType
        }

    }
}
