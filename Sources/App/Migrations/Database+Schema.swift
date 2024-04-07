import Fluent
import FluentSQL

extension Database {
  public func schema<Model: FluentKit.Model>(for: Model.Type) async throws -> SchemaBuilder {
    if let space = Model.space, let sqlDatabase = self as? any SQLDatabase {
      try await sqlDatabase.raw("CREATE SCHEMA IF NOT EXISTS \(ident: space)").run()
      return self.schema(Model.schema, space: space)
    }

    return self.schema(Model.schema)
  }

  public func schema<Model: FluentKit.Model>(for: Model.Type) -> SchemaBuilder {
    if let space = Model.space, let sqlDatabase = self as? any SQLDatabase {
      _ = sqlDatabase.raw("CREATE SCHEMA IF NOT EXISTS \(ident: space)").run()
      return self.schema(Model.schema, space: space)
    }

    return self.schema(Model.schema)
  }
}

extension DatabaseSchema.FieldConstraint {
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
