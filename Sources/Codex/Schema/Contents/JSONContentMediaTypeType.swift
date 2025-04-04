//
//  ContentMediaType.swift
//  Codex
//
//  Created by Kevin Wooten on 2/11/25.
//

public struct JSONContentMediaTypeType: Schema.ContentMediaTypeType {

  public let identifier: String = "application/json"

  public func validate(_ value: Value) -> Bool {
    guard case .string(let string) = value else { return false }
    do {
      try JSONValueReader(string: string).validateValue()
      return true
    } catch {
      return false
    }
  }

}
