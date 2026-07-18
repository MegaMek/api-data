/// Read-only public API for BattleTech static tech levels (e.g. Standard,
/// Advanced, Experimental, Unofficial) and the ammo/equipment/weapons at each
/// level. Registered under `/battletech/tech-levels` by
/// ``BattleTech/RootController``. There is no import endpoint here — tech level
/// rows are populated as a side effect of the ammo/equipment/weapon CSV imports
/// (via each row's `staticTechLevel()`).
import Fluent
import Vapor
import XMLCoder

extension BattleTech {
    /// A Vapor `RouteCollection` for `/battletech/tech-levels`.
    struct TechLevelController: RouteCollection {
        /// Groups routes under `/tech-levels`: `GET /` (list), and
        /// `GET`/`DELETE /:tech_level_id` plus the nested
        /// `ammo`/`equipment`/`weapons` listings for a tech level.
        ///
        /// - Parameter routes: The `RoutesBuilder` to register routes on.
        /// - Throws: Does not currently throw; matches Vapor's `boot(routes:)`
        ///   signature.
        func boot(routes: RoutesBuilder) throws {
            let techLevels = routes.grouped("tech-levels")
            techLevels.get(use: index).description("All Tech Levels")
            techLevels.group(":tech_level_id") { techLevel in
                techLevel.get(use: show).description("Individual Tech Level")
                techLevel.delete(use: delete).description("Delete Tech Level")
                techLevel.get("ammo", use: ammo).description("Ammo for Tech Level")
                techLevel.get("equipment", use: equipment).description("Equipment for Tech Level")
                techLevel.get("weapons", use: weapons).description("Weapons for Tech Level")
            }

        }

        /// Serves `GET /battletech/tech-levels`.
        ///
        /// - Parameter req: The incoming `Request`.
        /// - Returns: Every ``BattleTech/TechLevel`` row (unpaginated).
        /// - Throws: Rethrows errors from the database query.
        func index(req: Request) async throws -> [BattleTech.TechLevel] {
            try await BattleTech.TechLevel.query(on: req.db).all()
        }

        /// Serves `GET /battletech/tech-levels/:tech_level_id`.
        ///
        /// - Parameter req: The incoming `Request`; must include a valid
        ///   `tech_level_id` UUID path parameter (read via `req.parameters`).
        /// - Returns: The matching ``BattleTech/TechLevel`` row.
        /// - Throws: `Abort(.notFound)` if the id is missing, not a UUID, or
        ///   doesn't match any row.
        func show(req: Request) async throws -> BattleTech.TechLevel {
            try await getTechLevelForRequest(req: req)
        }

        /// Serves `DELETE /battletech/tech-levels/:tech_level_id`.
        ///
        /// - Parameter req: The incoming `Request`; must include a valid
        ///   `tech_level_id` UUID path parameter.
        /// - Returns: `204 No Content` on success.
        /// - Throws: `Abort(.notFound)` if the tech level doesn't exist;
        ///   rethrows database errors otherwise.
        func delete(req: Request) async throws -> HTTPStatus {
            let techLevel = try await getTechLevelForRequest(req: req)
            try await techLevel.delete(on: req.db)
            return .noContent
        }

        /// Serves `GET /battletech/tech-levels/:tech_level_id/ammo`.
        ///
        /// - Parameter req: The incoming `Request`; must include a valid
        ///   `tech_level_id` UUID path parameter, and honors pagination query
        ///   params (`page`, `per`).
        /// - Returns: A `Page` of ``BattleTech/Ammo`` rows at this tech level,
        ///   via the model's `$ammo` relation.
        /// - Throws: `Abort(.notFound)` if the tech level doesn't exist;
        ///   rethrows database errors otherwise.
        func ammo(req: Request) async throws -> Page<BattleTech.Ammo> {
            let techLevel = try await getTechLevelForRequest(req: req)
            return try await techLevel.$ammo.query(on: req.db).paginate(for: req)
        }

        /// Serves `GET /battletech/tech-levels/:tech_level_id/equipment`.
        ///
        /// - Parameter req: The incoming `Request`; must include a valid
        ///   `tech_level_id` UUID path parameter, and honors pagination query
        ///   params (`page`, `per`).
        /// - Returns: A `Page` of ``BattleTech/Equipment`` rows at this tech
        ///   level, via the model's `$equipment` relation.
        /// - Throws: `Abort(.notFound)` if the tech level doesn't exist;
        ///   rethrows database errors otherwise.
        func equipment(req: Request) async throws -> Page<BattleTech.Equipment> {
            let techLevel = try await getTechLevelForRequest(req: req)
            return try await techLevel.$equipment.query(on: req.db).paginate(for: req)
        }

        /// Serves `GET /battletech/tech-levels/:tech_level_id/weapons`.
        ///
        /// - Parameter req: The incoming `Request`; must include a valid
        ///   `tech_level_id` UUID path parameter, and honors pagination query
        ///   params (`page`, `per`).
        /// - Returns: A `Page` of ``BattleTech/Weapon`` rows at this tech level,
        ///   via the model's `$weapons` relation.
        /// - Throws: `Abort(.notFound)` if the tech level doesn't exist;
        ///   rethrows database errors otherwise.
        func weapons(req: Request) async throws -> Page<BattleTech.Weapon> {
            let techLevel = try await getTechLevelForRequest(req: req)
            return try await techLevel.$weapons.query(on: req.db).paginate(for: req)
        }

        /// Looks up the ``BattleTech/TechLevel`` row identified by the
        /// `tech_level_id` path parameter.
        ///
        /// - Parameter req: The incoming `Request` supplying the
        ///   `tech_level_id` path parameter.
        /// - Returns: The matching tech level row.
        /// - Throws: `Abort(.notFound)` if the id is missing, not a UUID, or
        ///   doesn't match any row.
        private func getTechLevelForRequest(req: Request) async throws -> BattleTech.TechLevel {
            guard let idString = req.parameters.get("tech_level_id"),
                let techLevelUUID = UUID(idString),
                let techLevel = try await BattleTech.TechLevel.query(on: req.db)
                    .filter(\.$id == techLevelUUID)
                    .first()
            else {
                throw Abort(.notFound)
            }

            return techLevel
        }
    }
}
