//
//  LocalMetaSchemaContainer.swift
//  Codex
//
//  Created by Kevin Wooten on 2/8/25.
//

import Foundation

public class MetaSchemaContainer: MetaSchemaLocator, @unchecked Sendable {

  private var schemas: [URI: MetaSchema]
  private let schemasLock: NSLock
  private let schemaLocator: SchemaLocator

  public init(schemas: [URI: MetaSchema] = [:], schemaLocator: SchemaLocator) {
    self.schemas = schemas
    self.schemasLock = NSLock()
    self.schemaLocator = schemaLocator
  }

  public func register(_ schema: MetaSchema) {
    schemasLock.withLock { schemas[schema.id] = schema }
  }

  public func locate(metaSchemaId: URI, options: Schema.Options) throws -> MetaSchema? {

    if let metaSchema = schemasLock.withLock({ schemas[metaSchemaId] }) {
      return metaSchema
    }

    guard
      let metaSchemaInstance = try schemaLocator.locate(schemaId: metaSchemaId, options: options)
    else {
      return nil
    }

    let metaSchema = MetaSchema.Builder.build(from: metaSchemaInstance)

    schemasLock.withLock {
      schemas[metaSchemaId] = metaSchema
      schemas[metaSchema.id] = metaSchema
    }

    return metaSchema
  }

}
