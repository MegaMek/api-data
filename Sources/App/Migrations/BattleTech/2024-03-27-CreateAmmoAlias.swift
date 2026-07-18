/// CreateAmmoAlias.swift
///
/// Fluent migration that creates the `ammo_alias` table, storing alternate/historical names for
/// an ammo record. Row data itself is populated/updated via a separate data-import process.
///
/// Author: Richard J Hancock
/// Date: 2024/03/23

import Fluent
import FluentSQL

extension BattleTech {
    /// Creates the `ammo_alias` table, which references `ammo` via a required `ammo_id`
    /// foreign key.
    struct CreateAmmoAlias: AsyncMigration {
        /// Creates the `ammo_alias` table.
        /// - Parameter database: The database connection to apply the schema change to.
        /// - Throws: An error if the schema change fails.
        func prepare(on database: any Database) async throws {
            try await database.schema(for: BattleTech.AmmoAlias.self)
                .id()
                .field(BattleTech.AmmoAlias.V20240327.name, .string, .required)
                .field(
                    BattleTech.AmmoAlias.V20240327.ammo,
                    .uuid,
                    .required,
                    .references(
                        BattleTech.Ammo.self,
                        BattleTech.Ammo.V20240327.id,
                        onDelete: .cascade
                    )
                )
                .unique(
                    on:
                        BattleTech.AmmoAlias.V20240327.name,
                    BattleTech.AmmoAlias.V20240327.ammo
                )
                .create()
        }

        /// Drops the `ammo_alias` table.
        /// - Parameter database: The database connection to apply the schema change to.
        /// - Throws: An error if the schema change fails.
        func revert(on database: any Database) async throws {
            try await database.schema(for: BattleTech.AmmoAlias.self).delete()
        }
    }
}

extension BattleTech.AmmoAlias {
    /// Column-name constants (``FieldKey``s) for the `ammo_alias` table, version 2024-03-27.
    enum V20240327 {
        static let schemaName = "ammo_alias"
        static let spaceName = "battletech"

        static let id = FieldKey(stringLiteral: "id")
        static let name = FieldKey(stringLiteral: "name")
        static let ammo = FieldKey(stringLiteral: "ammo_id")
    }
}
