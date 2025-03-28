import Fluent
import Vapor
import XMLCoder

extension BattleTech {
    struct RulesController: RouteCollection {
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

        func index(req: Request) async throws -> [BattleTech.Rule] {
            try await BattleTech.Rule.query(on: req.db).all()
        }

        func show(req: Request) async throws -> BattleTech.Rule {
            try await getRuleForRequest(req: req)
        }

        func delete(req: Request) async throws -> HTTPStatus {
            let rule = try await getRuleForRequest(req: req)
            try await rule.delete(on: req.db)
            return .noContent
        }

        func ammo(req: Request) async throws -> Page<BattleTech.Ammo> {
            let rule = try await getRuleForRequest(req: req)
            return try await rule.$ammo.query(on: req.db).paginate(for: req)
        }

        func equipment(req: Request) async throws -> Page<BattleTech.Equipment> {
            let rule = try await getRuleForRequest(req: req)
            return try await rule.$equipment.query(on: req.db).paginate(for: req)
        }

        func weapons(req: Request) async throws -> Page<BattleTech.Weapon> {
            let rule = try await getRuleForRequest(req: req)
            return try await rule.$weapons.query(on: req.db).paginate(for: req)
        }

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
