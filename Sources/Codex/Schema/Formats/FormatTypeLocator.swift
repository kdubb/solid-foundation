//
//  FormatTypeLocator.swift
//  Codex
//
//  Created by Kevin Wooten on 2/9/25.
//

public protocol FormatTypeLocator: Sendable {

  func locate(formatType id: String) throws -> Schema.FormatType

}
