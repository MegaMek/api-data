/// Read-only public API for BattleTech construction rules (e.g. Tournament
/// Legal, Standard, Advanced) and the ammo/equipment/weapons legal under each
/// rule. Registered under `/battletech/rules` by ``BattleTech/RootController``.
/// There is no import endpoint here — rule rows are populated as a side effect
/// of the ammo/equipment/weapon CSV imports (each row's `rules()` list is
/// resolved to `Rule` records during that import).
import Fluent
import Vapor
import XMLCoder

extension BattleTech {
    /// A Vapor `RouteCollection` for `/battletech/rules`.
    struct RulesController: RouteCollection {
        /// Groups routes under `/rules`: `GET /` (list), and
        /// `GET`/`DELETE /:rule_id` plus the nested `ammo`/`equipment`/`weapons`
        /// listings for a rule.
        ///
        /// - Parameter routes: The `RoutesBuilder` to register routes on.
        /// - Throws: Does not currently throw; matches Vapor's `boot(routes:)`
        ///   signature.
        func boot(routes: RoutesBuilder) throws {
            let rules = routes.grouped("rules")
            rules.get(use: index).description("All Rules")
            rules.group(":rule_id") { rule in
                rule.get(use: show).description("Individual Rule")
                rule.delete(use: delete).description("Delete Rule")
                rule.get("ammo", use: ammo).description("Ammo for Rule")
                rule.get("equipment", use: equipment).description("Equipment for Rule")
                rule.get("weapons", use: weapons).description("Weapons for Rule")
            }
        }

        /// Serves `GET /battletech/rules`.
        ///
        /// - Parameter req: The incoming `Request`.
        /// - Returns: Every ``BattleTech/Rule`` row (unpaginated).
        /// - Throws: Rethrows errors from the database query.
        func index(req: Request) async throws -> [BattleTech.Rule] {
            try await BattleTech.Rule.query(on: req.db).all()
        }

        /// Serves `GET /battletech/rules/:rule_id`.
        ///
        /// - Parameter req: The incoming `Request`; must include a valid
        ///   `rule_id` UUID path parameter (read via `req.parameters`).
        /// - Returns: The matching ``BattleTech/Rule`` row.
        /// - Throws: `Abort(.notFound)` if the id is missing, not a UUID, or
        ///   doesn't match any row.
        func show(req: Request) async throws -> BattleTech.Rule {
            try await getRuleForRequest(req: req)
        }

        /// Serves `DELETE /battletech/rules/:rule_id`.
        ///
        /// - Parameter req: The incoming `Request`; must include a valid
        ///   `rule_id` UUID path parameter.
        /// - Returns: `204 No Content` on success.
        /// - Throws: `Abort(.notFound)` if the rule doesn't exist; rethrows
        ///   database errors otherwise.
        func delete(req: Request) async throws -> HTTPStatus {
            let rule = try await getRuleForRequest(req: req)
            try await rule.delete(on: req.db)
            return .noContent
        }

        /// Serves `GET /battletech/rules/:rule_id/ammo`.
        ///
        /// - Parameter req: The incoming `Request`; must include a valid
        ///   `rule_id` UUID path parameter, and honors pagination query params
        ///   (`page`, `per`).
        /// - Returns: A `Page` of ``BattleTech/Ammo`` rows legal under this
        ///   rule, via the model's `$ammo` relation.
        /// - Throws: `Abort(.notFound)` if the rule doesn't exist; rethrows
        ///   database errors otherwise.
        func ammo(req: Request) async throws -> Page<BattleTech.Ammo> {
            let rule = try await getRuleForRequest(req: req)
            return try await rule.$ammo.query(on: req.db).paginate(for: req)
        }

        /// Serves `GET /battletech/rules/:rule_id/equipment`.
        ///
        /// - Parameter req: The incoming `Request`; must include a valid
        ///   `rule_id` UUID path parameter, and honors pagination query params
        ///   (`page`, `per`).
        /// - Returns: A `Page` of ``BattleTech/Equipment`` rows legal under this
        ///   rule, via the model's `$equipment` relation.
        /// - Throws: `Abort(.notFound)` if the rule doesn't exist; rethrows
        ///   database errors otherwise.
        func equipment(req: Request) async throws -> Page<BattleTech.Equipment> {
            let rule = try await getRuleForRequest(req: req)
            return try await rule.$equipment.query(on: req.db).paginate(for: req)
        }

        /// Serves `GET /battletech/rules/:rule_id/weapons`.
        ///
        /// - Parameter req: The incoming `Request`; must include a valid
        ///   `rule_id` UUID path parameter, and honors pagination query params
        ///   (`page`, `per`).
        /// - Returns: A `Page` of ``BattleTech/Weapon`` rows legal under this
        ///   rule, via the model's `$weapons` relation.
        /// - Throws: `Abort(.notFound)` if the rule doesn't exist; rethrows
        ///   database errors otherwise.
        func weapons(req: Request) async throws -> Page<BattleTech.Weapon> {
            let rule = try await getRuleForRequest(req: req)
            return try await rule.$weapons.query(on: req.db).paginate(for: req)
        }

        /// Looks up the ``BattleTech/Rule`` row identified by the `rule_id` path
        /// parameter.
        ///
        /// - Parameter req: The incoming `Request` supplying the `rule_id` path
        ///   parameter.
        /// - Returns: The matching rule row.
        /// - Throws: `Abort(.notFound)` if the id is missing, not a UUID, or
        ///   doesn't match any row.
        private func getRuleForRequest(req: Request) async throws -> BattleTech.Rule {
            guard let idString = req.parameters.get("rule_id"),
                let ruleUUID = UUID(idString),
                let rule = try await BattleTech.Rule.query(on: req.db)
                    .filter(\.$id == ruleUUID)
                    .first()
            else {
                throw Abort(.notFound)
            }

            return rule
        }
    }
}
