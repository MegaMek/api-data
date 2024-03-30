import Fluent
import XMLCoder
import Vapor

extension BattleTech {
    struct TechBaseController: RouteCollection {
        func boot(routes: RoutesBuilder) throws {
            let techBase = routes.grouped("tech-bases")
            techBase.get(use: index).description("All Tech Bases")
            techBase.group(":tech_base_id") { base in
                base.get(use: show).description("Individual Tech Base")
                base.get("ammo", use: ammo).description("Ammo for Tech Base")
                base.get("weapons", use: weapons).description("Weapons for Tech Base")
            }

        }

        func index(req: Request) async throws -> [BattleTech.TechBase] {
            try await BattleTech.TechBase.query(on: req.db(.replica)).all()
        }

        func show(req: Request) async throws -> BattleTech.TechBase {
            try await getTechBaseForRequest(req: req)
        }

        func ammo(req: Request) async throws -> Page<BattleTech.Ammo> {
            let rule = try await getTechBaseForRequest(req: req)
            return try await rule.$ammo.query(on: req.db(.replica)).paginate(for: req)
        }

        func weapons(req: Request) async throws -> Page<BattleTech.Weapon> {
            let rule = try await getTechBaseForRequest(req: req)
            return try await rule.$weapons.query(on: req.db(.replica)).paginate(for: req)
        }

        private func getTechBaseForRequest(req: Request) async throws -> BattleTech.TechBase {
            guard let idString = req.parameters.get("tech_base_id"),
                let techBaseUUID = UUID(idString),
                let techBase = try await BattleTech.TechBase.query(on: req.db(.replica))
                    .filter(\.$id == techBaseUUID)
                    .first() else {
                        throw Abort(.notFound)
            }

            return techBase
        }
    }
}
