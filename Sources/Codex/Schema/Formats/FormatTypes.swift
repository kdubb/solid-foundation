//
//  FormatTypes.swift
//  Codex
//
//  Created by Kevin Wooten on 2/9/25.
//

import Foundation

public struct FormatTypes: FormatTypeLocator, @unchecked Sendable {

  public enum Error: Swift.Error {
    case unknownFormat(String)
  }

  public private(set) var formats: [String: Schema.FormatType] = [:]
  private let lock = NSLock()

  public init() {
    // Register the default formats
  }

  public func locate(formatType id: String) throws -> Schema.FormatType {
    throw Error.unknownFormat(id)
  }

}
