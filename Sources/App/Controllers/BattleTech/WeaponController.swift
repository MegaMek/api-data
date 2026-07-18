/// Read-only public API for BattleTech weapon data, plus an admin CSV-upload
/// endpoint for (re)populating it. Registered under `/battletech/weapons` by
/// ``BattleTech/RootController``.
import Fluent
import SwiftCSV
import Vapor

extension BattleTech {
    /// A Vapor `RouteCollection` for `/battletech/weapons`.
    struct WeaponController: RouteCollection {
        /// Groups routes under `/weapons`: `GET /` (paginated list),
        /// `POST /import` (mass CSV import), and `GET`/`DELETE /:weapon_id`
        /// (single-item show/delete).
        ///
        /// - Parameter routes: The `RoutesBuilder` to register routes on.
        /// - Throws: Does not currently throw; matches Vapor's `boot(routes:)`
        ///   signature.
        func boot(routes: RoutesBuilder) throws {
            let weapons = routes.grouped("weapons")
            weapons.get(use: index).description("All Weapons")
            weapons.post("import", use: massCreate).description("Mass Create Weapons")
            weapons.group(":weapon_id") { weapon in
                weapon.get(use: show).description("Individual Weapon")
                weapon.delete(use: delete).description("Delete Weapon")
            }
        }

        /// Serves `GET /battletech/weapons`.
        ///
        /// - Parameter req: The incoming `Request`; standard Fluent pagination
        ///   query params (`page`, `per`) are honored via `paginate(for:)`.
        /// - Returns: A `Page` of ``BattleTech/Weapon`` rows, with their tech
        ///   base, applicable rules, static tech level, and aliases eagerly
        ///   loaded (via Fluent's `Model.query(on:)` + `.with(_:)`).
        /// - Throws: Rethrows errors from the database query.
        func index(req: Request) async throws -> Page<BattleTech.Weapon> {
            try await BattleTech.Weapon.query(on: req.db)
                .with(\.$techBase)
                .with(\.$rules)
                .with(\.$techLevelStatic)
                .with(\.$aliases)
                .paginate(for: req)
        }

        /// Serves `GET /battletech/weapons/:weapon_id`.
        ///
        /// - Parameter req: The incoming `Request`; must include a valid
        ///   `weapon_id` UUID path parameter (read via `req.parameters`).
        /// - Returns: The matching ``BattleTech/Weapon`` row with its relations
        ///   eagerly loaded.
        /// - Throws: `Abort(.notFound)` if the id is missing, not a UUID, or
        ///   doesn't match any row.
        func show(req: Request) async throws -> BattleTech.Weapon {
            return try await weaponForRequest(req: req)
        }

        /// Serves `DELETE /battletech/weapons/:weapon_id`.
        ///
        /// - Parameter req: The incoming `Request`; must include a valid
        ///   `weapon_id` UUID path parameter.
        /// - Returns: `204 No Content` on success.
        /// - Throws: `Abort(.notFound)` if the weapon doesn't exist; rethrows
        ///   database errors otherwise. Detaches the weapon's rules pivot rows
        ///   before deleting so the many-to-many join table doesn't dangle.
        func delete(req: Request) async throws -> HTTPStatus {
            let weapon = try await weaponForRequest(req: req)
            try await weapon.$rules.detachAll(on: req.db)
            try await weapon.delete(on: req.db)
            return .noContent
        }

        /// Serves `POST /battletech/weapons/import`. An admin-facing bulk-load
        /// endpoint: decodes an uploaded weapon CSV file (`req.content` reads the
        /// multipart body into a ``WeaponMassImport``), parses it row by row with
        /// ``Importers/WeaponCSVRow``, skips rows marked "Unofficial" in their
        /// rules/tech-level columns, and dispatches the rest as
        /// ``WeaponImportJob`` background jobs (each retried up to 5 times)
        /// rather than writing them to the database inline.
        ///
        /// - Parameter req: The incoming `Request`; the body must be
        ///   multipart/form-data containing a `file` field with CSV content.
        /// - Returns: `201 Created` once every row has been queued (not once
        ///   every row has actually been imported — importing happens
        ///   asynchronously).
        /// - Throws: Rethrows errors from decoding the upload or dispatching jobs.
        func massCreate(req: Request) async throws -> HTTPStatus {
            let input = try req.content.decode(WeaponMassImport.self)
            let csvString = String(decoding: Data(buffer: input.file.data), as: UTF8.self)
            let csv: CSV = try CSV<Enumerated>(string: csvString)

            for row in csv.rows {
                let csvRow = Importers.WeaponCSVRow(row: row)
                if csvRow.rulesReference().contains("Unofficial")
                    || csvRow.rulesRaw().contains("Unofficial")
                    || csvRow.staticTechLevel().contains("Unofficial")
                {
                    continue
                }

                try await req.queue.dispatch(WeaponImportJob.self, csvRow, maxRetryCount: 5)
            }

            return .created
        }

        /// Looks up the ``BattleTech/Weapon`` row identified by the `weapon_id`
        /// path parameter, with its relations eagerly loaded.
        ///
        /// - Parameter req: The incoming `Request` supplying the `weapon_id`
        ///   path parameter.
        /// - Returns: The matching weapon row.
        /// - Throws: `Abort(.notFound)` if the id is missing, not a UUID, or
        ///   doesn't match any row.
        private func weaponForRequest(req: Request) async throws -> BattleTech.Weapon {
            guard let weaponIdString = req.parameters.get("weapon_id"),
                let weaponUUID = UUID(weaponIdString),
                let weapon = try await BattleTech.Weapon.query(on: req.db)
                    .with(\.$techBase)
                    .with(\.$rules)
                    .with(\.$techLevelStatic)
                    .with(\.$aliases)
                    .filter(\.$id == weaponUUID)
                    .first()
            else {
                throw Abort(.notFound)
            }

            return weapon
        }
    }
}

/// The multipart form body expected by `POST /battletech/weapons/import`: a single
/// uploaded file containing the weapon CSV data.
struct WeaponMassImport: Content {
    var file: File
}
