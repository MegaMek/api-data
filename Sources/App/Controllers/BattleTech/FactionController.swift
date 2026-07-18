/// Read-only public API for BattleTech factions, plus an admin XML-upload
/// endpoint for (re)populating them. Registered under `/battletech/factions` by
/// ``BattleTech/RootController``.
import Fluent
import Vapor
import XMLCoder

extension BattleTech {
    /// A Vapor `RouteCollection` for `/battletech/factions`.
    struct FactionController: RouteCollection {
        /// Groups routes under `/factions`: `GET /` (list), `POST /import` (mass
        /// XML import), and `GET`/`DELETE /:faction_id` (single-item
        /// show/delete).
        ///
        /// - Parameter routes: The `RoutesBuilder` to register routes on.
        /// - Throws: Does not currently throw; matches Vapor's `boot(routes:)`
        ///   signature.
        func boot(routes: RoutesBuilder) throws {
            let factions = routes.grouped("factions")
            factions.get(use: index).description("All Factions")
            factions.post("import", use: massCreate).description("Mass Create Factions")
            factions.group(":faction_id") { faction in
                faction.get(use: show).description("Individual Faction")
                faction.delete(use: delete).description("Delete Faction")
            }
        }

        /// Serves `GET /battletech/factions`.
        ///
        /// - Parameter req: The incoming `Request`.
        /// - Returns: Every ``BattleTech/Faction`` row (unpaginated), with its
        ///   historical names, parent factions, and subfactions eagerly loaded.
        /// - Throws: Rethrows errors from the database query.
        func index(req: Request) async throws -> [BattleTech.Faction] {
            try await BattleTech.Faction.query(on: req.db)
                .with(\.$names)
                .with(\.$parents)
                .with(\.$subfactions)
                .all()
        }

        /// Serves `GET /battletech/factions/:faction_id`.
        ///
        /// - Parameter req: The incoming `Request`; must include a valid
        ///   `faction_id` UUID path parameter (read via `req.parameters`).
        /// - Returns: The matching ``BattleTech/Faction`` row with its relations
        ///   eagerly loaded.
        /// - Throws: `Abort(.notFound)` if the id is missing, not a UUID, or
        ///   doesn't match any row.
        func show(req: Request) async throws -> BattleTech.Faction {
            return try await factionForReq(req: req)
        }

        /// Serves `DELETE /battletech/factions/:faction_id`.
        ///
        /// - Parameter req: The incoming `Request`; must include a valid
        ///   `faction_id` UUID path parameter.
        /// - Returns: `204 No Content` on success.
        /// - Throws: `Abort(.notFound)` if the faction doesn't exist; rethrows
        ///   database errors otherwise.
        func delete(req: Request) async throws -> HTTPStatus {
            let faction = try await factionForReq(req: req)
            try await faction.delete(on: req.db)
            return .noContent
        }

        /// Serves `POST /battletech/factions/import`. An admin-facing bulk-load
        /// endpoint: decodes an uploaded faction XML file (`req.content` reads
        /// the multipart body into a ``FactionMassImport``) with `XMLDecoder`
        /// into ``Importers/Factions``, then processes it synchronously (no
        /// background job) in two passes: first every faction is
        /// created/updated and its name history rebuilt via
        /// ``BattleTech/Faction/findOrNew(importableFaction:on:)`` and
        /// ``BattleTech/Faction/updateName(importableFaction:on:)``; only once
        /// all factions exist does the second pass link parent/subfaction
        /// relationships via ``BattleTech/Faction/updateParent(importableFaction:on:)``,
        /// since a parent faction must already be in the database before it can
        /// be attached.
        ///
        /// - Parameter req: The incoming `Request`; the body must be
        ///   multipart/form-data containing a `file` field with faction XML
        ///   content.
        /// - Returns: `201 Created` once every faction has been imported and
        ///   linked.
        /// - Throws: Rethrows errors from decoding the upload/XML or from the
        ///   database upserts.
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

        /// Looks up the ``BattleTech/Faction`` row identified by the
        /// `faction_id` path parameter, with its relations eagerly loaded.
        ///
        /// - Parameter req: The incoming `Request` supplying the `faction_id`
        ///   path parameter.
        /// - Returns: The matching faction row.
        /// - Throws: `Abort(.notFound)` if the id is missing, not a UUID, or
        ///   doesn't match any row.
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

/// The multipart form body expected by `POST /battletech/factions/import`: a
/// single uploaded file containing the faction XML data.
struct FactionMassImport: Content {
    var file: File
}
