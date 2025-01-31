//
//  Value-Error.swift
//  Codex
//
//  Created by Kevin Wooten on 1/28/25.
//

extension Value {

  public enum Error: Swift.Error {
    case invalidInteger(Any & Sendable)
    case invalidDecimal(Any & Sendable)
  }

}
