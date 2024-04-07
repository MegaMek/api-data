import Fluent
import Vapor
import XMLCoder

extension BattleTech {
  struct MunitionTypeController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
      let munitionTypes = routes.grouped("munition-types")
      munitionTypes.get(use: index).description("All Munition Types")

      munitionTypes.group(":munition_type_id") { munitionType in
        munitionType.get(use: show).description("Individual Munition Type")
        munitionType.delete(use: delete).description("Delete Munition Type")
        munitionType.get("ammo", use: ammo).description("Ammo for Munition Type")
      }

    }

    func index(req: Request) async throws -> [BattleTech.MunitionType] {
      try await BattleTech.MunitionType.query(on: req.db).all()
    }

    func show(req: Request) async throws -> BattleTech.MunitionType {
      return try await getMunitionTypeForRequest(req: req)
    }

    func delete(req: Request) async throws -> HTTPStatus {
      let munitionType = try await getMunitionTypeForRequest(req: req)
      try await munitionType.delete(on: req.db(.primary))
      return .noContent
    }

    func ammo(req: Request) async throws -> Page<BattleTech.Ammo> {
      let rule = try await getMunitionTypeForRequest(req: req)
      return try await rule.$ammo.query(on: req.db(.replica)).paginate(for: req)
    }

    private func getMunitionTypeForRequest(req: Request) async throws -> BattleTech.MunitionType {
      guard let idString = req.parameters.get("munition_type_id"),
        let munitionTypeUUID = UUID(idString),
        let munitionType = try await BattleTech.MunitionType.query(on: req.db(.replica))
          .filter(\.$id == munitionTypeUUID)
          .first()
      else {
        throw Abort(.notFound)
      }

      return munitionType
    }

  }
}
