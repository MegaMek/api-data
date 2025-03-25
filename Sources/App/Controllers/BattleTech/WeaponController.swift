import Fluent
import SwiftCSV
import Vapor

extension BattleTech {
    struct WeaponController: RouteCollection {
        func boot(routes: RoutesBuilder) throws {
            let weapons = routes.grouped("weapons")
            weapons.get(use: index).description("All Weapons")
            weapons.post("import", use: massCreate).description("Mass Create Weapons")
            weapons.group(":weapon_id") { weapon in
                weapon.get(use: show).description("Individual Weapon")
                weapon.delete(use: delete).description("Delete Weapon")
            }
        }

        func index(req: Request) async throws -> Page<BattleTech.Weapon> {
            try await BattleTech.Weapon.query(on: req.db)
                .with(\.$techBase)
                .with(\.$rules)
                .with(\.$techLevelStatic)
                .with(\.$aliases)
                .paginate(for: req)
        }

        func show(req: Request) async throws -> BattleTech.Weapon {
            return try await weaponForRequest(req: req)
        }

        func delete(req: Request) async throws -> HTTPStatus {
            let weapon = try await weaponForRequest(req: req)
            try await weapon.$rules.detachAll(on: req.db(.primary))
            try await weapon.delete(on: req.db(.primary))
            return .noContent
        }

        func massCreate(req: Request) async throws -> HTTPStatus {
            let input = try req.content.decode(WeaponMassImport.self)
            let csvString = String(decoding: Data(buffer: input.file.data), as: UTF8.self)
            let csv: CSV = try CSV<Enumerated>(string: csvString)

            for row in csv.rows {
                let csvRow = Importers.WeaponCSVRow(row: row)
                if csvRow.rulesReference().contains("Unofficial")
                    || csvRow.rulesRaw().contains("Unofficial")
                    || csvRow.staticTechLevel().contains("Unofficial") {
                    continue
                }

                try await req.queue.dispatch(WeaponImportJob.self, csvRow, maxRetryCount: 5)
            }

            return .created
        }

        private func weaponForRequest(req: Request) async throws -> BattleTech.Weapon {
            guard let weaponIdString = req.parameters.get("weapon_id"),
                  let weaponUUID = UUID(weaponIdString),
                  let weapon = try await BattleTech.Weapon.query(on: req.db(.replica))
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

struct WeaponMassImport: Content {
    var file: File
}
