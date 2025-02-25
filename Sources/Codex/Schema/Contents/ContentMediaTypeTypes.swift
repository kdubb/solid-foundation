//
//  ContentMediaTypeTypes.swift
//  Codex
//
//  Created by Kevin Wooten on 2/9/25.
//

import Foundation

public final class ContentMediaTypeTypes: ContentMediaTypeLocator, @unchecked Sendable {

  public enum Error: Swift.Error {
    case contentTypeNotFound(String)
  }

  public private(set) var contentMediaTypes: [String: Schema.ContentMediaTypeType] = [:]
  private let lock = NSLock()

  public init() {
    // Register the default content types
    register(contentMediaType: JSONContentMediaTypeType())
  }

  public func locate(contentMediaType id: String) throws -> Schema.ContentMediaTypeType {
    try lock.withLock {
      guard let contentMediaType = contentMediaTypes[id] else {
        throw Error.contentTypeNotFound(id)
      }
      return contentMediaType
    }
  }

  public func register(contentMediaType: Schema.ContentMediaTypeType) {
    lock.withLock {
      contentMediaTypes[contentMediaType.identifier] = contentMediaType
    }
  }

}
