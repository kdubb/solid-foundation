//
//  FormatTypes.swift
//  Codex
//
//  Created by Kevin Wooten on 2/9/25.
//

public struct FormatTypes: FormatTypeLocator {

  public enum Error: Swift.Error {
    case unknownFormat(String)
  }

  public func locate(formatType id: String) throws -> Schema.FormatType {
    throw Error.unknownFormat(id)
  }

}
