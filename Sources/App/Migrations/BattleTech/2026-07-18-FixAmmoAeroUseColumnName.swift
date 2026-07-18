/// FixAmmoAeroUseColumnName.swift
///
/// Fluent migration that repairs a copy-paste bug in ``BattleTech/CreateAmmo``: the `aeroUse`
/// column was declared with the literal key `"FieldKey"` instead of a real column name, so any
/// database that already ran that migration has an `ammo` column literally named `FieldKey`.
/// This migration renames that column to `aero_use` to match the corrected
/// ``BattleTech/Ammo/V20240327/aeroUse`` key. On a fresh database — where `CreateAmmo` already
/// creates the column as `aero_use` — the rename is skipped as a no-op.
///
/// Author: Richard J Hancock
/// Date: 2026/07/18

import Fluent
import FluentSQL

extension BattleTech {
    /// Renames the `ammo` table's mistakenly-named `FieldKey` column to `aero_use`, if present.
    struct FixAmmoAeroUseColumnName: AsyncMigration {
        /// Renames `ammo."FieldKey"` to `ammo.aero_use` only if the old, mistakenly-named column
        /// still exists — a no-op on any database where `CreateAmmo` already used the corrected
        /// column name.
        /// - Parameter database: The database connection to apply the schema change to.
        /// - Throws: An error if the underlying `DO` block fails to run.
        func prepare(on database: any Database) async throws {
            guard let sqlDatabase = database as? any SQLDatabase,
                let space = BattleTech.Ammo.space
            else {
                return
            }

            try await sqlDatabase.raw(
                """
                DO $$
                BEGIN
                    IF EXISTS (
                        SELECT 1 FROM information_schema.columns
                        WHERE table_schema = \(literal: space)
                          AND table_name = \(literal: BattleTech.Ammo.schema)
                          AND column_name = 'FieldKey'
                    ) THEN
                        ALTER TABLE \(ident: space).\(ident: BattleTech.Ammo.schema)
                            RENAME COLUMN \(ident: "FieldKey") TO \(ident: "aero_use");
                    END IF;
                END $$;
                """
            ).run()
        }

        /// Intentionally a no-op: reverting would mean deliberately restoring the original
        /// `"FieldKey"` typo, which is never desirable.
        /// - Parameter database: The database connection (unused).
        func revert(on database: any Database) async throws {}
    }
}
