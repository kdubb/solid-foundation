//
//  ContentEncodingTypes.swift
//  Codex
//
//  Created by Kevin Wooten on 2/11/25.
//

import Foundation

public final class ContentEncodingTypes: ContentEncodingLocator, @unchecked Sendable {

  public enum Error: Swift.Error {
    case contentEncodingNotFound(String)
  }

  public private(set) var contentEncodings: [String: Schema.ContentEncodingType] = [:]
  private let lock = NSLock()

  public init() {
    // Register the default encodings
  }

  public func locate(contentEncoding id: String) throws -> Schema.ContentEncodingType {
    try lock.withLock {
      guard let contentType = contentEncodings[id] else {
        throw Error.contentEncodingNotFound(id)
      }
      return contentType
    }
  }

  public func register(contentEncoding: Schema.ContentEncodingType) {
    lock.withLock {
      contentEncodings[contentEncoding.identifier] = contentEncoding
    }
  }

}
