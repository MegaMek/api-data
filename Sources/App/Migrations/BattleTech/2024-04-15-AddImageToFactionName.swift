/// AddImageToFactionName.swift
///
/// Fluent migration that adds an `image_name` column to the existing `faction_names` table — a
/// schema alteration rather than a new-table migration.
///
/// Author: Richard J Hancock
/// Date: 2024/04/15

import Fluent
import FluentSQL

extension BattleTech {
    /// Adds the `image_name` column to `faction_names`.
    struct AddImageToFactionName: AsyncMigration {
        /// Adds the `image_name` field to the `faction_names` table.
        /// - Parameter database: The database connection to apply the schema change to.
        /// - Throws: An error if the schema change fails.
        func prepare(on database: any Database) async throws {
            try await database.schema(for: BattleTech.FactionName.self)
                .field(BattleTech.FactionName.V20240415.image, .string)
                .update()
        }

        /// Removes the `image_name` field from the `faction_names` table.
        /// - Parameter database: The database connection to apply the schema change to.
        /// - Throws: An error if the schema change fails.
        func revert(on database: any Database) async throws {
            try await database.schema(for: BattleTech.FactionName.self)
                .deleteField(BattleTech.FactionName.V20240415.image)
                .update()
        }
    }
}

extension BattleTech.FactionName {
    /// Column-name constant (``FieldKey``) for the `image_name` column added to
    /// `faction_names` by this migration.
    enum V20240415 {
        static let image = FieldKey(stringLiteral: "image_name")
    }
}
