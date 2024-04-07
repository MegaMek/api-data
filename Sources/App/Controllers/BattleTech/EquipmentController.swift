import Fluent
import SwiftCSV
import Vapor

extension BattleTech {
  struct EquipmentController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
      let equipment = routes.grouped("equipment")
      equipment.get(use: index).description("All Equipment")
      equipment.post("import", use: massCreate).description("Mass Create Equipment")
      equipment.group(":equipment_id") { item in
        item.get(use: show).description("Individual Equipment")
        item.delete(use: delete).description("Delete Equipment")
      }
    }

    func index(req: Request) async throws -> Page<BattleTech.Equipment> {
      try await BattleTech.Equipment.query(on: req.db)
        .with(\.$techBase)
        .with(\.$rules)
        .with(\.$techLevelStatic)
        .with(\.$aliases)
        .paginate(for: req)
    }

    func show(req: Request) async throws -> BattleTech.Equipment {
      return try await equipmentForReq(req: req)
    }

    func delete(req: Request) async throws -> HTTPStatus {
      let equipment = try await equipmentForReq(req: req)
      try await equipment.$rules.detachAll(on: req.db(.primary))
      try await equipment.delete(on: req.db(.primary))
      return .noContent
    }

    func massCreate(req: Request) async throws -> HTTPStatus {
      let input = try req.content.decode(EquipmentMassImport.self)
      let csvString = String(decoding: Data(buffer: input.file.data), as: UTF8.self)
      let csv: CSV = try CSV<Enumerated>(string: csvString)

      for row in csv.rows {
        let csvRow = Importers.EquipmentCSVRow(row: row)
        if csvRow.rulesReference().contains("Unofficial")
          || csvRow.rulesRaw().contains("Unofficial")
          || csvRow.staticTechLevel().contains("Unofficial")
        {
          continue
        }

        try await req.queue.dispatch(EquipmentImportJob.self, csvRow, maxRetryCount: 5)
      }

      return .created
    }

    private func equipmentForReq(req: Request) async throws -> BattleTech.Equipment {
      guard let equipmentIdString = req.parameters.get("equipment_id"),
        let equipmentUUID = UUID(equipmentIdString),
        let equipment = try await BattleTech.Equipment.query(on: req.db(.replica))
          .with(\.$techBase)
          .with(\.$rules)
          .with(\.$techLevelStatic)
          .with(\.$aliases)
          .filter(\.$id == equipmentUUID)
          .first()
      else {
        throw Abort(.notFound)
      }

      return equipment
    }
  }
}

struct EquipmentMassImport: Content {
  var file: File
}
