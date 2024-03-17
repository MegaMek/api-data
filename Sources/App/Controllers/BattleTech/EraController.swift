import Fluent
import XMLCoder
import Vapor

extension BattleTech {
    struct EraController: RouteCollection {
        func boot(routes: RoutesBuilder) throws {
            let eras = routes.grouped("eras")
            eras.get(use: index).description("All Eras")
            eras.get(":era_id", use: show).description("Individual Era")
            eras.post("import", use: massCreate).description("Mass Create Eras")
        }

        func index(req: Request) async throws -> [Era] {
            try await Era.query(on: req.db).all()
        }

        func show(req: Request) async throws -> Era {
            guard let era = try await Era.find(req.parameters.get("era_id"), on: req.db(.replica)) else {
                throw Abort(.notFound)
            }

            return era
        }

        func massCreate(req: Request) async throws -> HTTPStatus {
            let input = try req.content.decode(EraMassImport.self)
            let decoder = XMLDecoder()

            let xmlString = String(decoding: Data(buffer: input.file.data), as: UTF8.self)
            let eras = try decoder.decode(Importers.Eras.self, from: xmlString.data(using: .utf8)!)
            for era in eras.era {
                let newEra = try await BattleTech.Era.findOrNew(importableEra: era, on: req.db(.replica))
                try await newEra.save(on: req.db(.primary))
            }

            return .created
        }
    }
}

struct EraMassImport: Content {
    var file: File
}
