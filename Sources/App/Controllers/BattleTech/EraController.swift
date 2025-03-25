import Fluent
import Vapor
import XMLCoder

extension BattleTech {
    struct EraController: RouteCollection {
        func boot(routes: RoutesBuilder) throws {
            let eras = routes.grouped("eras")
            eras.get(use: index).description("All Eras")
            eras.post("import", use: massCreate).description("Mass Create Eras")
            eras.group(":era_id") { era in
                era.get(use: show).description("Individual Era")
                era.delete(use: delete).description("Delete Era")
            }
        }

        func index(req: Request) async throws -> [BattleTech.Era] {
            try await BattleTech.Era.query(on: req.db)
                .sort(\.$startYear)
                .all()
        }

        func show(req: Request) async throws -> BattleTech.Era {
            return try await eraForReq(req: req)
        }

        func delete(req: Request) async throws -> HTTPStatus {
            let era = try await eraForReq(req: req)
            try await era.delete(on: req.db(.primary))
            return .noContent
        }

        func massCreate(req: Request) async throws -> HTTPStatus {
            let input = try req.content.decode(EraMassImport.self)
            let decoder = XMLDecoder()

            let xmlString = String(decoding: Data(buffer: input.file.data), as: UTF8.self)
            let eras = try decoder.decode(Importers.Eras.self, from: xmlString.data(using: .utf8)!)
            let sortedEras = eras.era.sorted { ($0.end ?? 9999) < ($1.end ?? 9999) }
            var startYear = -1
            for era in sortedEras {
                let newEra = try await BattleTech.Era.findOrNew(
                    importableEra: era,
                    startYear: startYear + 1,
                    on: req.db(.replica)
                )
                try await newEra.save(on: req.db(.primary))
                startYear = era.end ?? 9999
            }

            return .created
        }

        private func eraForReq(req: Request) async throws -> BattleTech.Era {
            guard let eraIdString = req.parameters.get("era_id"),
                  let eraUUID = UUID(eraIdString),
                  let era = try await BattleTech.Era.query(on: req.db(.replica))
                .filter(\.$id == eraUUID)
                .first()
            else {
                throw Abort(.notFound)
            }

            return era
        }
    }
}

struct EraMassImport: Content {
    var file: File
}
