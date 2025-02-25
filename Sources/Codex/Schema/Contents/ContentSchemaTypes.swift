//
//  ContentSchemaTypes.swift
//  Codex
//
//  Created by Kevin Wooten on 2/11/25.
//

import Foundation

public final class ContentSchemaTypes: ContentSchemaLocator, @unchecked Sendable {

  public enum Error: Swift.Error {
    case contentSchemaNotFound(String)
  }

  public private(set) var contentSchemas: [String: Schema.ContentSchemaType] = [:]
  private let lock = NSLock()

  public init() {
    // Register the default schemas
  }

  public func locate(contentSchema id: String) throws -> Schema.ContentSchemaType {
    try lock.withLock {
      guard let contentType = contentSchemas[id] else {
        throw Error.contentSchemaNotFound(id)
      }
      return contentType
    }
  }

  public func register(contentSchema: Schema.ContentSchemaType) {
    lock.withLock {
      contentSchemas[contentSchema.identifier] = contentSchema
    }
  }

}
