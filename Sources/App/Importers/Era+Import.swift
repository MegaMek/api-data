/// Defines the shape of the era XML file uploaded to `POST /battletech/eras/import`
/// (handled by ``BattleTech/EraController/massCreate(req:)``) and the logic for
/// turning each parsed `<era>` element into a ``BattleTech/Era`` database row.
/// Unlike the CSV importers, this runs synchronously in the request rather than via
/// a background job.
//
// Era Importer Structure Definition and functions
//
// Author: Richard J Hancock
// Date: 2024/02/19

import FluentKit
import Foundation
import Vapor

extension Importers {
    /// The root element of the era XML file: a flat list of `<era>` entries.
    struct Eras: Codable {
        var era: [Importers.Era]
    }

    /// One `<era>` element from the XML file. `end` is the last in-universe year of
    /// the era; the era's start year is derived by the controller from the
    /// previous era's end year rather than stored in the file.
    struct Era: Codable {
        var code: String
        var name: String
        var end: Int?
        var flag: String
        var icon: String?
        var mulid: Int?
    }
}

extension BattleTech.Era {
    /// Finds the existing ``BattleTech/Era`` matching an imported era's `code`, or
    /// builds a new (unsaved) one, applying the imported fields either way. The
    /// caller is responsible for calling `save(on:)` on the result.
    ///
    /// - Parameters:
    ///   - importableEra: The parsed `<era>` XML element to import.
    ///   - startYear: The start year to assign, computed by the caller from the
    ///     previous era's end year (eras are contiguous, sorted by end year).
    ///   - database: The `Database` to search for an existing matching era in.
    /// - Returns: The existing era (updated in memory) or a new, unsaved era.
    /// - Throws: Rethrows errors from the database lookup.
    static func findOrNew(
        importableEra: Importers.Era,
        startYear: Int,
        on database: Database
    ) async throws
    -> BattleTech.Era
    {
        guard
            let foundEra = try await BattleTech.Era.query(on: database)
                .filter(\.$code == importableEra.code)
                .first()
        else {
            return BattleTech.Era(
                code: importableEra.code,
                name: importableEra.name,
                startYear: startYear,
                endYear: importableEra.end ?? -1,
                flag: importableEra.flag,
                icon: importableEra.icon ?? nil,
                mulId: importableEra.mulid ?? -1
            )
        }

        foundEra.name = importableEra.name
        foundEra.startYear = startYear
        foundEra.endYear = importableEra.end ?? 9999
        foundEra.flag = importableEra.flag
        foundEra.icon = importableEra.icon ?? nil
        foundEra.mulId = importableEra.mulid ?? -1

        return foundEra
    }
}
