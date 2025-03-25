// Era Importer Structure Definition and functions
//
// Author: Richard J Hancock
// Date: 2024/02/19

import FluentKit
import Foundation
import Vapor
import XMLCoder

extension Importers {
    struct Factions: Codable {
        let faction: [Importers.Faction]
    }

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

    struct FactionNameChange: Codable {
        let year: Int
        let value: String
        var image: String?
    }
}

extension Importers.FactionNameChange: DynamicNodeDecoding {
    enum CodingKeys: String, CodingKey {
        case year
        case image
        case value = ""
    }

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

    func updateName(
        importableFaction: Importers.Faction,
        on database: Database
    ) async throws {
        try await self.$names.query(on: database).delete()
        let years = importableFaction.years.split(separator: ",", omittingEmptySubsequences: true)
        for range in years {
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
                foundName.name = nameChange.value
                try await foundName.save(on: database)
            } else {
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
