import Fluent
import SwiftCSV
import Vapor

extension BattleTech {
    struct EquipmentController: RouteCollection {
        func boot(routes: RoutesBuilder) throws {
            let equipment = routes.grouped("equipment")
            equipment.get(use: index).description("All Equipment")
            equipment.get(":equipment_id", use: show).description("Individual Equipment")
            equipment.post("import", use: massCreate).description("Mass Create Equipment")
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
            guard let equipmentIdString = req.parameters.get("equipment_id"),
              let equipmentUUID = UUID(equipmentIdString),
              let equipment = try await BattleTech.Equipment.query(on: req.db(.replica))
                .with(\.$techBase)
                .with(\.$rules)
                .with(\.$techLevelStatic)
                .with(\.$aliases)
                .filter(\.$id == equipmentUUID)
                .first() else {
                throw Abort(.notFound)
            }

            return equipment
        }

        func massCreate(req: Request) async throws -> HTTPStatus {
            let input = try req.content.decode(EquipmentMassImport.self)
            let csvString = String(decoding: Data(buffer: input.file.data), as: UTF8.self)
            let csv: CSV = try CSV<Enumerated>(string: csvString)

            for row in csv.rows {
                let csvRow = Importers.EquipmentCSVRow(row: row)
                if csvRow.rulesReference().contains("Unofficial") ||
                    csvRow.rulesRaw().contains("Unofficial") ||
                    csvRow.staticTechLevel().contains("Unofficial") {
                    continue
                }

                _ = try await BattleTech.Equipment.findOrCreate(
                    csvRow: csvRow,
                    on: req.db(.replica)
                )
            }

            return .created
        }
    }
}

struct EquipmentMassImport: Content {
    var file: File
}
