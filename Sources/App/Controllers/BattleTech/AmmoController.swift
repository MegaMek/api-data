import Fluent
import SwiftCSV
import Vapor

extension BattleTech {
    struct AmmoController: RouteCollection {
        func boot(routes: RoutesBuilder) throws {
            let ammo = routes.grouped("ammo")
            ammo.get(use: index).description("All Ammo")
            ammo.get(":ammo_id", use: show).description("Individual Ammo")
            ammo.post("import", use: massCreate).description("Mass Create Ammo")
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
            guard let ammoIdString = req.parameters.get("ammo_id"),
              let ammoUUID = UUID(ammoIdString),
              let ammo = try await BattleTech.Ammo.query(on: req.db(.replica))
                .with(\.$techBase)
                .with(\.$rules)
                .with(\.$techLevelStatic)
                .with(\.$munitionType)
                .with(\.$aliases)
                .filter(\.$id == ammoUUID)
                .first() else {
                throw Abort(.notFound)
            }

            return ammo
        }

        func massCreate(req: Request) async throws -> HTTPStatus {
            let input = try req.content.decode(AmmoMassImport.self)
            let csvString = String(decoding: Data(buffer: input.file.data), as: UTF8.self)
            let csv: CSV = try CSV<Enumerated>(string: csvString)

            for row in csv.rows {
                let csvRow = Importers.AmmoCSVRow(row: row)
                if csvRow.rulesReference().contains("Unofficial") ||
                    csvRow.rulesRaw().contains("Unofficial") ||
                    csvRow.staticTechLevel().contains("Unofficial") {
                    continue
                }

                _ = try await BattleTech.Ammo.findOrCreate(
                    csvRow: csvRow,
                    on: req.db(.replica)
                )
            }

            return .created
        }
    }
}

struct AmmoMassImport: Content {
    var file: File
}
