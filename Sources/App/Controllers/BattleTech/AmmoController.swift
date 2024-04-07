import Fluent
import SwiftCSV
import Vapor

extension BattleTech {
  struct AmmoController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
      let ammo = routes.grouped("ammo")
      ammo.get(use: index).description("All Ammo")
      ammo.post("import", use: massCreate).description("Mass Create Ammo")
      ammo.group(":ammo_id") { item in
        item.get(use: show).description("Individual Ammo")
        item.delete(use: delete).description("Delete Ammo")
      }
    }

    func index(req: Request) async throws -> Page<BattleTech.Ammo> {
      try await BattleTech.Ammo.query(on: req.db)
        .with(\.$techBase)
        .with(\.$rules)
        .with(\.$techLevelStatic)
        .with(\.$munitionType)
        .with(\.$aliases)
        .paginate(for: req)
    }

    func show(req: Request) async throws -> BattleTech.Ammo {
      return try await ammoForRequest(req: req)
    }

    func delete(req: Request) async throws -> HTTPStatus {
      let ammo = try await ammoForRequest(req: req)
      try await ammo.$rules.detachAll(on: req.db(.primary))
      try await ammo.delete(on: req.db(.primary))
      return .noContent
    }

    func massCreate(req: Request) async throws -> HTTPStatus {
      let input = try req.content.decode(AmmoMassImport.self)
      let csvString = String(decoding: Data(buffer: input.file.data), as: UTF8.self)
      let csv: CSV = try CSV<Enumerated>(string: csvString)

      for row in csv.rows {
        let csvRow = Importers.AmmoCSVRow(row: row)
        if csvRow.rulesReference().contains("Unofficial")
          || csvRow.rulesRaw().contains("Unofficial")
          || csvRow.staticTechLevel().contains("Unofficial")
        {
          continue
        }

        try await req.queue.dispatch(AmmoImportJob.self, csvRow, maxRetryCount: 5)
      }

      return .created
    }

    private func ammoForRequest(req: Request) async throws -> BattleTech.Ammo {
      guard let ammoIdString = req.parameters.get("ammo_id"),
        let ammoUUID = UUID(ammoIdString),
        let ammo = try await BattleTech.Ammo.query(on: req.db(.replica))
          .with(\.$techBase)
          .with(\.$rules)
          .with(\.$techLevelStatic)
          .with(\.$munitionType)
          .with(\.$aliases)
          .filter(\.$id == ammoUUID)
          .first()
      else {
        throw Abort(.notFound)
      }

      return ammo
    }
  }
}

struct AmmoMassImport: Content {
  var file: File
}
