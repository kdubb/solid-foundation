//
//  MetaSchema-Builder.swift
//  Codex
//
//  Created by Kevin Wooten on 2/9/25.
//

extension MetaSchema {

  public struct Builder {

    public static func build(
      from schemaInstance: Value,
      resourceId: URI = Schema.Builder.defaultId,
      options: Schema.Options = .default
    ) throws -> MetaSchema {

      let schema = try Schema.Builder.build(from: schemaInstance, resourceId: resourceId, options: options)

      return try build(from: schema)
    }

    public static func build(from schema: Schema) throws -> MetaSchema {

      let vocabularies = schema.behavior(Schema.Identifiers.Vocabulary$.self)?.vocabularies ?? []

      return MetaSchema(
        id: schema.id,
        vocabularies: vocabularies,
        keywordBehaviors: [:],
        schemaLocator: schema
      )

    }

  }

}
