/// Defines the shape of the faction XML file uploaded to
/// `POST /battletech/factions/import` (handled by
/// ``BattleTech/FactionController/massCreate(req:)``) and the logic for turning
/// each parsed `<faction>` element (including its name-history and parent-faction
/// data) into ``BattleTech/Faction`` and ``BattleTech/FactionName`` database rows.
/// This runs synchronously in the request rather than via a background job.
//
// Era Importer Structure Definition and functions
//
// Author: Richard J Hancock
// Date: 2024/02/19

import FluentKit
import Foundation
import Vapor
import XMLCoder

extension Importers {
    /// The root element of the faction XML file: a flat list of `<faction>`
    /// entries.
    struct Factions: Codable {
        let faction: [Importers.Faction]
    }

    /// One `<faction>` element from the XML file, including its current name,
    /// the years it has existed (as a comma-separated list of ranges), an
    /// optional parent-faction key (or comma-separated keys for multiple
    /// parents), and any historical name changes.
    struct Faction: Codable {
        let key: String
        let name: String
        let minor: Bool
        let clan: Bool
        let periphery: Bool
        let years: String
        var image: String?
        var ratingLevels: String?
        var parentFaction: String?
        var nameChange: [FactionNameChange]?
    }

    /// One historical rename of a faction: the year it took effect, the new
    /// name, and an optional image reference.
    struct FactionNameChange: Codable {
        let year: Int
        let value: String
        var image: String?
    }
}

/// Tells `XMLCoder` how to decode `<nameChange>` elements: `year` and `image` are
/// XML attributes, while the new name itself is the element's text content
/// (mapped to the empty-string coding key).
extension Importers.FactionNameChange: DynamicNodeDecoding {
    enum CodingKeys: String, CodingKey {
        case year
        case image
        case value = ""
    }

    /// Reports, per coding key, whether it should be decoded from an XML
    /// attribute or from element content.
    ///
    /// - Parameter key: The coding key being decoded.
    /// - Returns: `.attribute` for `year`/`image`, `.element` otherwise.
    static func nodeDecoding(for key: any CodingKey) -> XMLCoder.XMLDecoder.NodeDecoding {
        switch key {
        case CodingKeys.year, CodingKeys.image:
            return .attribute
        default:
            return .element
        }
    }
}

extension BattleTech.Faction {
    /// Finds the existing ``BattleTech/Faction`` matching an imported faction's
    /// `key`, or builds a new (unsaved) one, applying the imported fields either
    /// way. The caller is responsible for calling `save(on:)` on the result.
    ///
    /// - Parameters:
    ///   - importableFaction: The parsed `<faction>` XML element to import.
    ///   - database: The `Database` to search for an existing matching faction in.
    /// - Returns: The existing faction (updated in memory) or a new, unsaved
    ///   faction.
    /// - Throws: Rethrows errors from the database lookup.
    static func findOrNew(
        importableFaction: Importers.Faction,
        on database: Database
    ) async throws -> BattleTech.Faction {
        guard
            let foundFaction = try await BattleTech.Faction.query(on: database)
                .filter(\.$factionKey == importableFaction.key)
                .first()
        else {
            return BattleTech.Faction(
                factionKey: importableFaction.key,
                minor: importableFaction.minor,
                clan: importableFaction.clan,
                periphery: importableFaction.periphery,
                ratingLevels: importableFaction.ratingLevels ?? "")
        }

        foundFaction.minor = importableFaction.minor
        foundFaction.clan = importableFaction.clan
        foundFaction.periphery = importableFaction.periphery
        foundFaction.ratingLevels = importableFaction.ratingLevels ?? ""

        return foundFaction
    }

    /// Links a faction to its parent faction(s) by attaching pivot rows for each
    /// key in the imported faction's (possibly comma-separated) `parentFaction`
    /// field. Called only after all factions have already been created/updated,
    /// since a parent faction must exist in the database before it can be
    /// attached.
    ///
    /// - Parameters:
    ///   - importableFaction: The parsed `<faction>` XML element whose parent
    ///     links should be applied.
    ///   - database: The `Database` to look up the faction and its parents in.
    /// - Throws: Rethrows errors from the database lookups or attach operation.
    static func updateParent(
        importableFaction: Importers.Faction,
        on database: Database
    ) async throws {
        guard let parentFactionKey = importableFaction.parentFaction else { return }

        guard
            let faction = try await BattleTech.Faction.query(on: database)
                .filter(\.$factionKey == importableFaction.key)
                .first()
        else { return }

        let factionKeys = parentFactionKey.split(separator: ",", omittingEmptySubsequences: true)
        for parentKey in factionKeys {
            guard
                let parentFaction = try await BattleTech.Faction.query(on: database)
                    .filter(\.$factionKey == String(parentKey))
                    .first()
            else { return }

            try await faction.$parents.attach(parentFaction, method: .ifNotExists, on: database)
        }
    }

    /// Rebuilds this faction's name history from the imported data: clears any
    /// existing ``BattleTech/FactionName`` rows, recreates one per year-range in
    /// `importableFaction.years` using the faction's current name, then applies
    /// any explicit historical renames via ``nameChangeUpdates(importableFaction:on:)``.
    ///
    /// - Parameters:
    ///   - importableFaction: The parsed `<faction>` XML element supplying the
    ///     name and year ranges.
    ///   - database: The `Database` to read/write faction-name rows on.
    /// - Throws: Rethrows errors from the delete/create operations.
    func updateName(
        importableFaction: Importers.Faction,
        on database: Database
    ) async throws {
        try await self.$names.query(on: database).delete()
        let years = importableFaction.years.split(separator: ",", omittingEmptySubsequences: true)
        for range in years {
            // Each comma-separated entry is either a single year ("3025") or a
            // "start-end" range ("3025-3050"); parse out whichever bounds are present.
            let startAndEndYears = range.split(separator: "-", omittingEmptySubsequences: true)
            var startYear: Int?
            var endYear: Int?

            if let year = startAndEndYears.first {
                startYear = Int(String(year))
            }

            if startAndEndYears.count == 2, let year = startAndEndYears.last {
                endYear = Int(String(year))
            }

            try await BattleTech.FactionName.findOrNew(
                faction: self,
                name: importableFaction.name,
                startYear: startYear,
                endYear: endYear,
                image: importableFaction.image,
                on: database
            )
        }

        try await nameChangeUpdates(importableFaction: importableFaction, on: database)
    }

    /// Applies any explicit `<nameChange>` entries on top of the name history
    /// built by ``updateName(importableFaction:on:)``: for each rename year, either
    /// updates the ``BattleTech/FactionName`` row already starting that year, or
    /// splits the preceding name period so the new name starts on the correct
    /// year.
    ///
    /// - Parameters:
    ///   - importableFaction: The parsed `<faction>` XML element supplying the
    ///     `nameChange` entries.
    ///   - database: The `Database` to read/write faction-name rows on.
    /// - Throws: Rethrows errors from the database lookups or saves; force-unwraps
    ///   the previous name period, so malformed source data (a name change with no
    ///   prior name period) will crash.
    func nameChangeUpdates(
        importableFaction: Importers.Faction,
        on database: Database
    ) async throws {
        guard let nameChanges = importableFaction.nameChange else { return }
        for nameChange in nameChanges {
            if let foundName = try await self.$names.query(on: database)
                .filter(\.$startYear == nameChange.year)
                .first()
            {
                // A name period already starts exactly on the change year; just rename it.
                foundName.name = nameChange.value
                try await foundName.save(on: database)
            } else {
                // No period starts on this year: split the preceding period so it ends
                // the year before, and insert a new period starting on the change year.
                let previousName = try await self.$names.query(on: database)
                    .filter(\.$startYear < nameChange.year)
                    .first()!

                let newName = BattleTech.FactionName(
                    name: nameChange.value,
                    startYear: nameChange.year,
                    endYear: previousName.endYear,
                    image: nameChange.image
                )

                newName.$faction.id = self.id!
                try await newName.save(on: database)

                previousName.endYear = nameChange.year - 1
                try await previousName.save(on: database)
            }
        }
    }
}

extension BattleTech.FactionName {
    /// Finds the existing ``BattleTech/FactionName`` period for a faction starting
    /// in `startYear`, updating it in place, or creates and saves a new one if
    /// none exists.
    ///
    /// - Parameters:
    ///   - faction: The faction this name period belongs to.
    ///   - name: The faction's display name during this period.
    ///   - startYear: The first in-universe year this name applies, if known.
    ///   - endYear: The last in-universe year this name applies, if known.
    ///   - image: An optional image/flag reference for this name period.
    ///   - database: The `Database` to read/write the faction-name row on.
    /// - Throws: Rethrows errors from the database lookup or save.
    static func findOrNew(
        faction: BattleTech.Faction,
        name: String,
        startYear: Int?,
        endYear: Int?,
        image: String?,
        on database: Database
    ) async throws {
        if let foundFactionName = try await faction.$names.query(on: database)
            .filter(\.$startYear == startYear)
            .first()
        {
            foundFactionName.name = name
            foundFactionName.startYear = startYear
            foundFactionName.endYear = endYear
            foundFactionName.image = image
            try await foundFactionName.save(on: database)
        } else {
            let factionName = BattleTech.FactionName(
                name: name, startYear: startYear, endYear: endYear, image: image)
            factionName.$faction.id = faction.id!
            try await factionName.save(on: database)
        }
    }
}
