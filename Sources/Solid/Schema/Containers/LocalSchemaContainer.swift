//
//  LocalSchemaContainer.swift
//  SolidFoundation
//
//  Created by Kevin Wooten on 2/8/25.
//

import Foundation

public final class LocalSchemaContainer: SchemaLocator {

  public static let empty = LocalSchemaContainer()

  public enum Error: Swift.Error {
    case schemaAlreadyResolved(URI)
  }

  private var schemasStorage: [URI: Schema]
  private let lock = NSLock()

  public var schemas: [URI: Schema] {
    lock.withLock { schemasStorage }
  }

  public init(schemas: [URI: Schema] = [:]) {
    self.schemasStorage = schemas
  }

  public func locate(schemaId: URI, options: Schema.Options) -> Schema? {
    let schemaResourceId = schemaId.removing(.query, .fragment)
    return lock.withLock {
      schemasStorage[schemaResourceId]
    }
  }

  public func register(schema: Schema) {
    lock.withLock {
      schemasStorage[schema.id] = schema
      for resourceId in schema.resources.map(\.id) {
        schemasStorage[resourceId] = schema
      }
    }
  }

}

extension LocalSchemaContainer: @unchecked Sendable {}
