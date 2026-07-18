/// Read-only public API for BattleTech ammo data, plus an admin CSV-upload
/// endpoint for (re)populating it. Registered under `/battletech/ammo` by
/// ``BattleTech/RootController``.
import Fluent
import SwiftCSV
import Vapor

extension BattleTech {
    /// A Vapor `RouteCollection` for `/battletech/ammo`.
    struct AmmoController: RouteCollection {
        /// Groups routes under `/ammo`: `GET /` (paginated list),
        /// `POST /import` (mass CSV import), and `GET`/`DELETE /:ammo_id`
        /// (single-item show/delete).
        ///
        /// - Parameter routes: The `RoutesBuilder` to register routes on.
        /// - Throws: Does not currently throw; matches Vapor's `boot(routes:)`
        ///   signature.
        func boot(routes: RoutesBuilder) throws {
            let ammo = routes.grouped("ammo")
            ammo.get(use: index).description("All Ammo")
            ammo.post("import", use: massCreate).description("Mass Create Ammo")
            ammo.group(":ammo_id") { item in
                item.get(use: show).description("Individual Ammo")
                item.delete(use: delete).description("Delete Ammo")
            }
        }

        /// Serves `GET /battletech/ammo`.
        ///
        /// - Parameter req: The incoming `Request`; standard Fluent pagination
        ///   query params (`page`, `per`) are honored via `paginate(for:)`.
        /// - Returns: A `Page` of ``BattleTech/Ammo`` rows, with their tech base,
        ///   applicable rules, static tech level, munition type, and aliases
        ///   eagerly loaded (via Fluent's `Model.query(on:)` + `.with(_:)`, so
        ///   related rows are fetched up front instead of lazily per-item).
        /// - Throws: Rethrows errors from the database query.
        func index(req: Request) async throws -> Page<BattleTech.Ammo> {
            try await BattleTech.Ammo.query(on: req.db)
                .with(\.$techBase)
                .with(\.$rules)
                .with(\.$techLevelStatic)
                .with(\.$munitionType)
                .with(\.$aliases)
                .paginate(for: req)
        }

        /// Serves `GET /battletech/ammo/:ammo_id`.
        ///
        /// - Parameter req: The incoming `Request`; must include a valid
        ///   `ammo_id` UUID path parameter (read via `req.parameters`).
        /// - Returns: The matching ``BattleTech/Ammo`` row with its relations
        ///   eagerly loaded.
        /// - Throws: `Abort(.notFound)` if the id is missing, not a UUID, or
        ///   doesn't match any row.
        func show(req: Request) async throws -> BattleTech.Ammo {
            return try await ammoForRequest(req: req)
        }

        /// Serves `DELETE /battletech/ammo/:ammo_id`.
        ///
        /// - Parameter req: The incoming `Request`; must include a valid
        ///   `ammo_id` UUID path parameter.
        /// - Returns: `204 No Content` on success.
        /// - Throws: `Abort(.notFound)` if the ammo doesn't exist; rethrows
        ///   database errors otherwise. Detaches the ammo's rules pivot rows
        ///   before deleting so the many-to-many join table doesn't dangle.
        func delete(req: Request) async throws -> HTTPStatus {
            let ammo = try await ammoForRequest(req: req)
            try await ammo.$rules.detachAll(on: req.db)
            try await ammo.delete(on: req.db)
            return .noContent
        }

        /// Serves `POST /battletech/ammo/import`. An admin-facing bulk-load
        /// endpoint: decodes an uploaded ammo CSV file (`req.content` reads the
        /// multipart body into an ``AmmoMassImport``), parses it row by row with
        /// ``Importers/AmmoCSVRow``, skips rows marked "Unofficial" in their
        /// rules/tech-level columns, and dispatches the rest as ``AmmoImportJob``
        /// background jobs (each retried up to 5 times) rather than writing them
        /// to the database inline.
        ///
        /// - Parameter req: The incoming `Request`; the body must be
        ///   multipart/form-data containing a `file` field with CSV content.
        /// - Returns: `201 Created` once every row has been queued (not once
        ///   every row has actually been imported — importing happens
        ///   asynchronously).
        /// - Throws: Rethrows errors from decoding the upload or dispatching jobs.
        func massCreate(req: Request) async throws -> HTTPStatus {
            let input = try req.content.decode(AmmoMassImport.self)
            let csvString = String(bytes: Data(buffer: input.file.data), encoding: .utf8) ?? ""
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

        /// Looks up the ``BattleTech/Ammo`` row identified by the `ammo_id` path
        /// parameter, with its relations eagerly loaded.
        ///
        /// - Parameter req: The incoming `Request` supplying the `ammo_id`
        ///   path parameter.
        /// - Returns: The matching ammo row.
        /// - Throws: `Abort(.notFound)` if the id is missing, not a UUID, or
        ///   doesn't match any row.
        private func ammoForRequest(req: Request) async throws -> BattleTech.Ammo {
            guard let ammoIdString = req.parameters.get("ammo_id"),
                let ammoUUID = UUID(ammoIdString),
                let ammo = try await BattleTech.Ammo.query(on: req.db)
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

/// The multipart form body expected by `POST /battletech/ammo/import`: a single
/// uploaded file containing the ammo CSV data.
struct AmmoMassImport: Content {
    var file: File
}
