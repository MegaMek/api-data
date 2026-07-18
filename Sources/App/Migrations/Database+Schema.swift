///  Database+Schema.swift
///
///  Shared helpers used by every migration in this project (see `APIMigrations.swift` for
///  the ordered list of migrations that use them). This file is not itself a migration —
///  it extends Fluent's `Database` and `DatabaseSchema.FieldConstraint` types so individual
///  migrations can create tables inside a named Postgres schema/namespace (e.g. `security`,
///  `megamek`, via a model's `static var space`) and declare foreign keys that correctly
///  reference a model living in a different schema/space.

import Fluent
import FluentSQL

extension Database {
    /// Returns the schema builder for `Model`, first creating the model's Postgres
    /// schema/namespace (e.g. `security`) if it declares one via `Model.space`.
    /// - Parameter for: The Fluent model type whose table/schema builder is being resolved.
    /// - Returns: A `SchemaBuilder` for the model's table, scoped to its schema/space if any.
    /// - Throws: An error if the `CREATE SCHEMA IF NOT EXISTS` statement fails to run.
    public func schema<Model: FluentKit.Model>(for: Model.Type) async throws -> SchemaBuilder {
        if let space = Model.space, let sqlDatabase = self as? any SQLDatabase {
            try await sqlDatabase.raw("CREATE SCHEMA IF NOT EXISTS \(ident: space)").run()
            return self.schema(Model.schema, space: space)
        }

        return self.schema(Model.schema)
    }

    /// Synchronous variant of the same lookup. Note: the `CREATE SCHEMA IF NOT EXISTS`
    /// statement is fired without being awaited, so prefer the `async throws` overload
    /// above where the caller can wait for schema creation to complete.
    /// - Parameter for: The Fluent model type whose table/schema builder is being resolved.
    /// - Returns: A `SchemaBuilder` for the model's table, scoped to its schema/space if any.
    public func schema<Model: FluentKit.Model>(for: Model.Type) -> SchemaBuilder {
        if let space = Model.space, let sqlDatabase = self as? any SQLDatabase {
            _ = sqlDatabase.raw("CREATE SCHEMA IF NOT EXISTS \(ident: space)").run()
            return self.schema(Model.schema, space: space)
        }

        return self.schema(Model.schema)
    }
}

extension DatabaseSchema.FieldConstraint {
    /// Builds a foreign-key field constraint referencing `field` on `modelType`, resolving
    /// the target's schema/space (e.g. `security`) automatically so cross-schema foreign
    /// keys (e.g. `megamek.servers` referencing `security.users`) work without callers
    /// having to spell out the target schema by hand.
    /// - Parameters:
    ///   - modelType: The Fluent model type being referenced.
    ///   - field: The `FieldKey` of the referenced column (typically the target's `id`).
    ///   - onDelete: Action to take when the referenced row is deleted. Defaults to `.noAction`.
    ///   - onUpdate: Action to take when the referenced row is updated. Defaults to `.noAction`.
    /// - Returns: A field constraint usable with `.references(...)` in a migration.
    public static func references(
        _ modelType: (some Model).Type,
        _ field: FieldKey,
        onDelete: DatabaseSchema.ForeignKeyAction = .noAction,
        onUpdate: DatabaseSchema.ForeignKeyAction = .noAction
    ) -> Self {
        self.references(
            modelType.schema, space: modelType.space, field, onDelete: onDelete, onUpdate: onUpdate)
    }
}
