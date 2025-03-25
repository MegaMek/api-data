import Fluent
import Vapor
import XMLCoder

extension BattleTech {
    struct FactionController: RouteCollection {
        func boot(routes: RoutesBuilder) throws {
            let factions = routes.grouped("factions")
            factions.get(use: index).description("All Factions")
            factions.post("import", use: massCreate).description("Mass Create Factions")
            factions.group(":faction_id") { faction in
                faction.get(use: show).description("Individual Faction")
                faction.delete(use: delete).description("Delete Faction")
            }
        }

        func index(req: Request) async throws -> [BattleTech.Faction] {
            try await BattleTech.Faction.query(on: req.db)
                .with(\.$names)
                .with(\.$parents)
                .with(\.$subfactions)
                .all()
        }

        func show(req: Request) async throws -> BattleTech.Faction {
            return try await factionForReq(req: req)
        }

        func delete(req: Request) async throws -> HTTPStatus {
            let faction = try await factionForReq(req: req)
            try await faction.delete(on: req.db)
            return .noContent
        }

        func massCreate(req: Request) async throws -> HTTPStatus {
            let input = try req.content.decode(FactionMassImport.self)
            let decoder = XMLDecoder()

            let xmlString = String(decoding: Data(buffer: input.file.data), as: UTF8.self)
            let factions = try decoder.decode(
                Importers.Factions.self, from: xmlString.data(using: .utf8)!)

            // Create Factions
            for faction in factions.faction {
                let newFaction = try await BattleTech.Faction.findOrNew(
                    importableFaction: faction,
                    on: req.db
                )
                try await newFaction.save(on: req.db)
                try await newFaction.updateName(importableFaction: faction, on: req.db)
            }

            // Link Parents
            for faction in factions.faction {
                try await BattleTech.Faction.updateParent(
                    importableFaction: faction,
                    on: req.db
                )
            }

            return .created
        }

        private func factionForReq(req: Request) async throws -> BattleTech.Faction {
            guard let factionIdString = req.parameters.get("faction_id"),
                let factionUUID = UUID(factionIdString),
                let faction = try await BattleTech.Faction.query(on: req.db)
                    .with(\.$names)
                    .with(\.$parents)
                    .with(\.$subfactions)
                    .filter(\.$id == factionUUID)
                    .first()
            else {
                throw Abort(.notFound)
            }

            return faction
        }

    }
}

struct FactionMassImport: Content {
    var file: File
}
