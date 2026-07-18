/// Read-only public API for BattleTech equipment data, plus an admin CSV-upload
/// endpoint for (re)populating it. Registered under `/battletech/equipment` by
/// ``BattleTech/RootController``.
import Fluent
import SwiftCSV
import Vapor

extension BattleTech {
    /// A Vapor `RouteCollection` for `/battletech/equipment`.
    struct EquipmentController: RouteCollection {
        /// Groups routes under `/equipment`: `GET /` (paginated list),
        /// `POST /import` (mass CSV import), and `GET`/`DELETE /:equipment_id`
        /// (single-item show/delete).
        ///
        /// - Parameter routes: The `RoutesBuilder` to register routes on.
        /// - Throws: Does not currently throw; matches Vapor's `boot(routes:)`
        ///   signature.
        func boot(routes: RoutesBuilder) throws {
            let equipment = routes.grouped("equipment")
            equipment.get(use: index).description("All Equipment")
            equipment.post("import", use: massCreate).description("Mass Create Equipment")
            equipment.group(":equipment_id") { item in
                item.get(use: show).description("Individual Equipment")
                item.delete(use: delete).description("Delete Equipment")
            }
        }

        /// Serves `GET /battletech/equipment`.
        ///
        /// - Parameter req: The incoming `Request`; standard Fluent pagination
        ///   query params (`page`, `per`) are honored via `paginate(for:)`.
        /// - Returns: A `Page` of ``BattleTech/Equipment`` rows, with their tech
        ///   base, applicable rules, static tech level, and aliases eagerly
        ///   loaded (via Fluent's `Model.query(on:)` + `.with(_:)`).
        /// - Throws: Rethrows errors from the database query.
        func index(req: Request) async throws -> Page<BattleTech.Equipment> {
            try await BattleTech.Equipment.query(on: req.db)
                .with(\.$techBase)
                .with(\.$rules)
                .with(\.$techLevelStatic)
                .with(\.$aliases)
                .paginate(for: req)
        }

        /// Serves `GET /battletech/equipment/:equipment_id`.
        ///
        /// - Parameter req: The incoming `Request`; must include a valid
        ///   `equipment_id` UUID path parameter (read via `req.parameters`).
        /// - Returns: The matching ``BattleTech/Equipment`` row with its relations
        ///   eagerly loaded.
        /// - Throws: `Abort(.notFound)` if the id is missing, not a UUID, or
        ///   doesn't match any row.
        func show(req: Request) async throws -> BattleTech.Equipment {
            return try await equipmentForReq(req: req)
        }

        /// Serves `DELETE /battletech/equipment/:equipment_id`.
        ///
        /// - Parameter req: The incoming `Request`; must include a valid
        ///   `equipment_id` UUID path parameter.
        /// - Returns: `204 No Content` on success.
        /// - Throws: `Abort(.notFound)` if the equipment doesn't exist; rethrows
        ///   database errors otherwise. Detaches the equipment's rules pivot rows
        ///   before deleting so the many-to-many join table doesn't dangle.
        func delete(req: Request) async throws -> HTTPStatus {
            let equipment = try await equipmentForReq(req: req)
            try await equipment.$rules.detachAll(on: req.db)
            try await equipment.delete(on: req.db)
            return .noContent
        }

        /// Serves `POST /battletech/equipment/import`. An admin-facing bulk-load
        /// endpoint: decodes an uploaded equipment CSV file (`req.content` reads
        /// the multipart body into an ``EquipmentMassImport``), parses it row by
        /// row with ``Importers/EquipmentCSVRow``, skips rows marked "Unofficial"
        /// in their rules/tech-level columns, and dispatches the rest as
        /// ``EquipmentImportJob`` background jobs (each retried up to 5 times)
        /// rather than writing them to the database inline.
        ///
        /// - Parameter req: The incoming `Request`; the body must be
        ///   multipart/form-data containing a `file` field with CSV content.
        /// - Returns: `201 Created` once every row has been queued (not once
        ///   every row has actually been imported — importing happens
        ///   asynchronously).
        /// - Throws: Rethrows errors from decoding the upload or dispatching jobs.
        func massCreate(req: Request) async throws -> HTTPStatus {
            let input = try req.content.decode(EquipmentMassImport.self)
            let csvString = String(bytes: Data(buffer: input.file.data), encoding: .utf8) ?? ""
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

        /// Looks up the ``BattleTech/Equipment`` row identified by the
        /// `equipment_id` path parameter, with its relations eagerly loaded.
        ///
        /// - Parameter req: The incoming `Request` supplying the `equipment_id`
        ///   path parameter.
        /// - Returns: The matching equipment row.
        /// - Throws: `Abort(.notFound)` if the id is missing, not a UUID, or
        ///   doesn't match any row.
        private func equipmentForReq(req: Request) async throws -> BattleTech.Equipment {
            guard let equipmentIdString = req.parameters.get("equipment_id"),
                let equipmentUUID = UUID(equipmentIdString),
                let equipment = try await BattleTech.Equipment.query(on: req.db)
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

/// The multipart form body expected by `POST /battletech/equipment/import`: a
/// single uploaded file containing the equipment CSV data.
struct EquipmentMassImport: Content {
    var file: File
}
