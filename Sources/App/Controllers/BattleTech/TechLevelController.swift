import Fluent
import Vapor
import XMLCoder

extension BattleTech {
    struct TechLevelController: RouteCollection {
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

        func index(req: Request) async throws -> [BattleTech.TechLevel] {
            try await BattleTech.TechLevel.query(on: req.db(.replica)).all()
        }

        func show(req: Request) async throws -> BattleTech.TechLevel {
            try await getTechLevelForRequest(req: req)
        }

        func delete(req: Request) async throws -> HTTPStatus {
            let techLevel = try await getTechLevelForRequest(req: req)
            try await techLevel.delete(on: req.db(.primary))
            return .noContent
        }

        func ammo(req: Request) async throws -> Page<BattleTech.Ammo> {
            let techLevel = try await getTechLevelForRequest(req: req)
            return try await techLevel.$ammo.query(on: req.db(.replica)).paginate(for: req)
        }

        func equipment(req: Request) async throws -> Page<BattleTech.Equipment> {
            let techLevel = try await getTechLevelForRequest(req: req)
            return try await techLevel.$equipment.query(on: req.db(.replica)).paginate(for: req)
        }

        func weapons(req: Request) async throws -> Page<BattleTech.Weapon> {
            let techLevel = try await getTechLevelForRequest(req: req)
            return try await techLevel.$weapons.query(on: req.db(.replica)).paginate(for: req)
        }

        private func getTechLevelForRequest(req: Request) async throws -> BattleTech.TechLevel {
            guard let idString = req.parameters.get("tech_level_id"),
                  let techLevelUUID = UUID(idString),
                  let techLevel = try await BattleTech.TechLevel.query(on: req.db(.replica))
                .filter(\.$id == techLevelUUID)
                .first()
            else {
                throw Abort(.notFound)
            }

            return techLevel
        }
    }
}
