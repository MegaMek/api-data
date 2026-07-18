/// Read-only public API for BattleTech tech bases (Inner Sphere, Clan, Mixed,
/// etc.) and the ammo/equipment/weapons that use each one. Registered under
/// `/battletech/tech-bases` by ``BattleTech/RootController``. There is no import
/// endpoint here — tech base rows are populated as a side effect of the
/// ammo/equipment/weapon CSV imports.
import Fluent
import Vapor
import XMLCoder

extension BattleTech {
    /// A Vapor `RouteCollection` for `/battletech/tech-bases`.
    struct TechBaseController: RouteCollection {
        /// Groups routes under `/tech-bases`: `GET /` (list), and
        /// `GET`/`DELETE /:tech_base_id` plus the nested
        /// `ammo`/`equipment`/`weapons` listings for a tech base.
        ///
        /// - Parameter routes: The `RoutesBuilder` to register routes on.
        /// - Throws: Does not currently throw; matches Vapor's `boot(routes:)`
        ///   signature.
        func boot(routes: RoutesBuilder) throws {
            let techBase = routes.grouped("tech-bases")
            techBase.get(use: index).description("All Tech Bases")
            techBase.group(":tech_base_id") { base in
                base.get(use: show).description("Individual Tech Base")
                base.delete(use: delete).description("Delete Tech Base")
                base.get("ammo", use: ammo).description("Ammo for Tech Base")
                base.get("equipment", use: equipment).description("Equipment for Tech Base")
                base.get("weapons", use: weapons).description("Weapons for Tech Base")
            }
        }

        /// Serves `GET /battletech/tech-bases`.
        ///
        /// - Parameter req: The incoming `Request`.
        /// - Returns: Every ``BattleTech/TechBase`` row (unpaginated).
        /// - Throws: Rethrows errors from the database query.
        func index(req: Request) async throws -> [BattleTech.TechBase] {
            try await BattleTech.TechBase.query(on: req.db).all()
        }

        /// Serves `GET /battletech/tech-bases/:tech_base_id`.
        ///
        /// - Parameter req: The incoming `Request`; must include a valid
        ///   `tech_base_id` UUID path parameter (read via `req.parameters`).
        /// - Returns: The matching ``BattleTech/TechBase`` row.
        /// - Throws: `Abort(.notFound)` if the id is missing, not a UUID, or
        ///   doesn't match any row.
        func show(req: Request) async throws -> BattleTech.TechBase {
            try await getTechBaseForRequest(req: req)
        }

        /// Serves `DELETE /battletech/tech-bases/:tech_base_id`.
        ///
        /// - Parameter req: The incoming `Request`; must include a valid
        ///   `tech_base_id` UUID path parameter.
        /// - Returns: `204 No Content` on success.
        /// - Throws: `Abort(.notFound)` if the tech base doesn't exist; rethrows
        ///   database errors otherwise.
        func delete(req: Request) async throws -> HTTPStatus {
            let techBase = try await getTechBaseForRequest(req: req)
            try await techBase.delete(on: req.db)
            return .noContent
        }

        /// Serves `GET /battletech/tech-bases/:tech_base_id/ammo`.
        ///
        /// - Parameter req: The incoming `Request`; must include a valid
        ///   `tech_base_id` UUID path parameter, and honors pagination query
        ///   params (`page`, `per`).
        /// - Returns: A `Page` of ``BattleTech/Ammo`` rows using this tech base,
        ///   via the model's `$ammo` relation.
        /// - Throws: `Abort(.notFound)` if the tech base doesn't exist; rethrows
        ///   database errors otherwise.
        func ammo(req: Request) async throws -> Page<BattleTech.Ammo> {
            let techBase = try await getTechBaseForRequest(req: req)
            return try await techBase.$ammo.query(on: req.db).paginate(for: req)
        }

        /// Serves `GET /battletech/tech-bases/:tech_base_id/equipment`.
        ///
        /// - Parameter req: The incoming `Request`; must include a valid
        ///   `tech_base_id` UUID path parameter, and honors pagination query
        ///   params (`page`, `per`).
        /// - Returns: A `Page` of ``BattleTech/Equipment`` rows using this tech
        ///   base, via the model's `$equipment` relation.
        /// - Throws: `Abort(.notFound)` if the tech base doesn't exist; rethrows
        ///   database errors otherwise.
        func equipment(req: Request) async throws -> Page<BattleTech.Equipment> {
            let techBase = try await getTechBaseForRequest(req: req)
            return try await techBase.$equipment.query(on: req.db).paginate(for: req)
        }

        /// Serves `GET /battletech/tech-bases/:tech_base_id/weapons`.
        ///
        /// - Parameter req: The incoming `Request`; must include a valid
        ///   `tech_base_id` UUID path parameter, and honors pagination query
        ///   params (`page`, `per`).
        /// - Returns: A `Page` of ``BattleTech/Weapon`` rows using this tech
        ///   base, via the model's `$weapons` relation.
        /// - Throws: `Abort(.notFound)` if the tech base doesn't exist; rethrows
        ///   database errors otherwise.
        func weapons(req: Request) async throws -> Page<BattleTech.Weapon> {
            let techBase = try await getTechBaseForRequest(req: req)
            return try await techBase.$weapons.query(on: req.db).paginate(for: req)
        }

        /// Looks up the ``BattleTech/TechBase`` row identified by the
        /// `tech_base_id` path parameter.
        ///
        /// - Parameter req: The incoming `Request` supplying the `tech_base_id`
        ///   path parameter.
        /// - Returns: The matching tech base row.
        /// - Throws: `Abort(.notFound)` if the id is missing, not a UUID, or
        ///   doesn't match any row.
        private func getTechBaseForRequest(req: Request) async throws -> BattleTech.TechBase {
            guard let idString = req.parameters.get("tech_base_id"),
                let techBaseUUID = UUID(idString),
                let techBase = try await BattleTech.TechBase.query(on: req.db)
                    .filter(\.$id == techBaseUUID)
                    .first()
            else {
                throw Abort(.notFound)
            }

            return techBase
        }
    }
}
