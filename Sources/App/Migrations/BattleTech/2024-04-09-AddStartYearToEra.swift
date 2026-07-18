/// AddStartYearToEras.swift
///
/// Fluent migration that adds a `start_year` column to the existing `eras` table — a schema
/// alteration rather than a new-table migration.
///
/// Author: Richard J Hancock
/// Date: 2024/02/12

import Fluent
import FluentSQL

extension BattleTech {
    /// Adds the `start_year` column to `eras`.
    ///
    /// Unlike the `Create*` migrations above, this one alters an existing table rather than
    /// creating a new one: ``prepare(on:)`` adds the field, ``revert(on:)`` removes it again.
    struct AddStartYearToEras: AsyncMigration {
        /// Adds the `start_year` field to the `eras` table.
        /// - Parameter database: The database connection to apply the schema change to.
        /// - Throws: An error if the schema change fails.
        func prepare(on database: any Database) async throws {
            try await database.schema(for: BattleTech.Era.self)
                .field(BattleTech.Era.V20240409.startYear, .int)
                .update()
        }

        /// Removes the `start_year` field from the `eras` table.
        /// - Parameter database: The database connection to apply the schema change to.
        /// - Throws: An error if the schema change fails.
        func revert(on database: any Database) async throws {
            try await database.schema(for: BattleTech.Era.self)
                .deleteField(BattleTech.Era.V20240409.startYear)
                .update()
        }
    }
}

extension BattleTech.Era {
    /// Column-name constant (``FieldKey``) for the `start_year` column added to `eras` by this
    /// migration. Only new/changed columns get their own version namespace here — unchanged
    /// columns keep referencing the enum from the migration that introduced them (e.g.
    /// ``V20240212``).
    enum V20240409 {
        static let startYear = FieldKey(stringLiteral: "start_year")
    }
}
