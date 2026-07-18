/// CreateEras.swift
///
/// Fluent migration that creates the `eras` table, storing BattleTech's game-timeline eras
/// (e.g. Succession Wars, Clan Invasion) based on data sourced from MegaMek's XML.
///
/// Author: Richard J Hancock
/// Date: 2024/02/12

import Fluent
import FluentSQL

extension BattleTech {
    /// Creates the `eras` table.
    ///
    /// This is a Fluent ``AsyncMigration``: a versioned, ordered database-schema change.
    /// ``prepare(on:)`` applies the change (run when migrating up) and ``revert(on:)`` undoes it
    /// (run when rolling back). Vapor tracks which migrations have already run so each one is
    /// applied at most once.
    struct CreateEras: AsyncMigration {
        /// Creates the `eras` table with its columns, uniqueness constraints, and timestamps.
        /// - Parameter database: The database connection to apply the schema change to.
        /// - Throws: An error if the schema change fails.
        func prepare(on database: any Database) async throws {
            try await database.schema(for: BattleTech.Era.self)
                .id()
                .field(BattleTech.Era.V20240212.code, .string, .required)
                .field(BattleTech.Era.V20240212.name, .string, .required)
                .field(BattleTech.Era.V20240212.endYear, .int)
                .field(BattleTech.Era.V20240212.flag, .string, .required)
                .field(BattleTech.Era.V20240212.icon, .string)
                .field(BattleTech.Era.V20240212.mulId, .int)

                .field(BattleTech.Era.V20240212.publishedAt, .datetime)
                .field(BattleTech.Era.V20240212.createdAt, .datetime)
                .field(BattleTech.Era.V20240212.updatedAt, .datetime)

                .unique(on: BattleTech.Era.V20240212.name)
                .unique(on: BattleTech.Era.V20240212.endYear)
                .unique(on: BattleTech.Era.V20240212.flag)
                .create()
        }

        /// Drops the `eras` table.
        /// - Parameter database: The database connection to apply the schema change to.
        /// - Throws: An error if the schema change fails.
        func revert(on database: any Database) async throws {
            try await database.schema(for: BattleTech.Era.self).delete()
        }
    }
}

extension BattleTech.Era {
    /// Column-name constants (``FieldKey``s) for the `eras` table as of the 2024-02-12 schema
    /// version. Keeping these fixed per schema version means a later rename of a Swift property
    /// on ``BattleTech/Era`` won't silently change, or break, the actual database column name
    /// and existing data.
    enum V20240212 {
        static let schemaName = "eras"
        static let spaceName = "battletech"

        static let id = FieldKey(stringLiteral: "id")
        static let name = FieldKey(stringLiteral: "name")
        static let code = FieldKey(stringLiteral: "code")
        static let endYear = FieldKey(stringLiteral: "end_year")
        static let flag = FieldKey(stringLiteral: "flag")
        static let icon = FieldKey(stringLiteral: "icon")
        static let mulId = FieldKey(stringLiteral: "mul_id")

        static let publishedAt = FieldKey(stringLiteral: "published_at")
        static let createdAt = FieldKey(stringLiteral: "created_at")
        static let updatedAt = FieldKey(stringLiteral: "updated_at")
    }
}
