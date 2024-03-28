import Fluent
import SwiftCSV
import Vapor

extension BattleTech {
    struct WeaponController: RouteCollection {
        func boot(routes: RoutesBuilder) throws {
            let weapons = routes.grouped("weapons")
            weapons.get(use: index).description("All Weapons")
            weapons.get(":weapon_id", use: show).description("Individual Weapon")
            weapons.post("import", use: massCreate).description("Mass Create Weapons")
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
            guard let weaponIdString = req.parameters.get("weapon_id"),
              let weaponUUID = UUID(weaponIdString),
              let weapon = try await BattleTech.Weapon.query(on: req.db(.replica))
                .with(\.$techBase)
                .with(\.$rules)
                .with(\.$techLevelStatic)
                .with(\.$aliases)
                .filter(\.$id == weaponUUID)
                .first() else {
                throw Abort(.notFound)
            }

            return weapon
        }

        func massCreate(req: Request) async throws -> HTTPStatus {
            let input = try req.content.decode(WeaponMassImport.self)
            let csvString = String(decoding: Data(buffer: input.file.data), as: UTF8.self)
            let csv: CSV = try CSV<Enumerated>(string: csvString)

            for row in csv.rows {
                let csvRow = Importers.WeaponCSVRow(row: row)
                if csvRow.rulesReference().contains("Unofficial") {
                    continue
                }

                _ = try await BattleTech.Weapon.findOrCreate(
                    csvRow: csvRow,
                    on: req.db(.replica)
                )
            }

            return .created
        }
    }
}

struct WeaponMassImport: Content {
    var file: File
}
