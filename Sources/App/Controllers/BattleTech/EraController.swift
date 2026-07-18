/// Read-only public API for BattleTech historical eras, plus an admin XML-upload
/// endpoint for (re)populating them. Registered under `/battletech/eras` by
/// ``BattleTech/RootController``.
import Fluent
import Vapor
import XMLCoder

extension BattleTech {
    /// A Vapor `RouteCollection` for `/battletech/eras`.
    struct EraController: RouteCollection {
        /// Groups routes under `/eras`: `GET /` (list), `POST /import` (mass XML
        /// import), and `GET`/`DELETE /:era_id` (single-item show/delete).
        ///
        /// - Parameter routes: The `RoutesBuilder` to register routes on.
        /// - Throws: Does not currently throw; matches Vapor's `boot(routes:)`
        ///   signature.
        func boot(routes: RoutesBuilder) throws {
            let eras = routes.grouped("eras")
            eras.get(use: index).description("All Eras")
            eras.post("import", use: massCreate).description("Mass Create Eras")
            eras.group(":era_id") { era in
                era.get(use: show).description("Individual Era")
                era.delete(use: delete).description("Delete Era")
            }
        }

        /// Serves `GET /battletech/eras`.
        ///
        /// - Parameter req: The incoming `Request`.
        /// - Returns: Every ``BattleTech/Era`` row, sorted chronologically by
        ///   `startYear` (unpaginated, since there are only a handful of eras).
        /// - Throws: Rethrows errors from the database query.
        func index(req: Request) async throws -> [BattleTech.Era] {
            try await BattleTech.Era.query(on: req.db)
                .sort(\.$startYear)
                .all()
        }

        /// Serves `GET /battletech/eras/:era_id`.
        ///
        /// - Parameter req: The incoming `Request`; must include a valid
        ///   `era_id` UUID path parameter (read via `req.parameters`).
        /// - Returns: The matching ``BattleTech/Era`` row.
        /// - Throws: `Abort(.notFound)` if the id is missing, not a UUID, or
        ///   doesn't match any row.
        func show(req: Request) async throws -> BattleTech.Era {
            return try await eraForReq(req: req)
        }

        /// Serves `DELETE /battletech/eras/:era_id`.
        ///
        /// - Parameter req: The incoming `Request`; must include a valid
        ///   `era_id` UUID path parameter.
        /// - Returns: `204 No Content` on success.
        /// - Throws: `Abort(.notFound)` if the era doesn't exist; rethrows
        ///   database errors otherwise.
        func delete(req: Request) async throws -> HTTPStatus {
            let era = try await eraForReq(req: req)
            try await era.delete(on: req.db)
            return .noContent
        }

        /// Serves `POST /battletech/eras/import`. An admin-facing bulk-load
        /// endpoint: decodes an uploaded era XML file (`req.content` reads the
        /// multipart body into an ``EraMassImport``) with `XMLDecoder` into
        /// ``Importers/Eras``, sorts the parsed eras by end year, then — unlike
        /// the CSV importers — processes them synchronously (no background job):
        /// each era's `startYear` is computed as one year after the previous
        /// era's end year, and ``BattleTech/Era/findOrNew(importableEra:startYear:on:)``
        /// upserts the corresponding database row.
        ///
        /// - Parameter req: The incoming `Request`; the body must be
        ///   multipart/form-data containing a `file` field with era XML content.
        /// - Returns: `201 Created` once every era has been imported.
        /// - Throws: Rethrows errors from decoding the upload/XML or from the
        ///   database upserts.
        func massCreate(req: Request) async throws -> HTTPStatus {
            let input = try req.content.decode(EraMassImport.self)
            let decoder = XMLDecoder()

            let xmlString = String(bytes: Data(buffer: input.file.data), encoding: .utf8) ?? ""
            let eras = try decoder.decode(Importers.Eras.self, from: xmlString.data(using: .utf8)!)
            let sortedEras = eras.era.sorted { ($0.end ?? 9999) < ($1.end ?? 9999) }
            var startYear = -1
            for era in sortedEras {
                let newEra = try await BattleTech.Era.findOrNew(
                    importableEra: era,
                    startYear: startYear + 1,
                    on: req.db
                )
                try await newEra.save(on: req.db)
                startYear = era.end ?? 9999
            }

            return .created
        }

        /// Looks up the ``BattleTech/Era`` row identified by the `era_id` path
        /// parameter.
        ///
        /// - Parameter req: The incoming `Request` supplying the `era_id` path
        ///   parameter.
        /// - Returns: The matching era row.
        /// - Throws: `Abort(.notFound)` if the id is missing, not a UUID, or
        ///   doesn't match any row.
        private func eraForReq(req: Request) async throws -> BattleTech.Era {
            guard let eraIdString = req.parameters.get("era_id"),
                let eraUUID = UUID(eraIdString),
                let era = try await BattleTech.Era.query(on: req.db)
                    .filter(\.$id == eraUUID)
                    .first()
            else {
                throw Abort(.notFound)
            }

            return era
        }
    }
}

/// The multipart form body expected by `POST /battletech/eras/import`: a single
/// uploaded file containing the era XML data.
struct EraMassImport: Content {
    var file: File
}
