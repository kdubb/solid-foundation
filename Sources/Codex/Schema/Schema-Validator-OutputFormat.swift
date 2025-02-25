//
//  Schema-Validator-OutputFormat.swift
//  Codex
//
//  Created by Kevin Wooten on 2/7/25.
//

extension Schema.Validator {

  public enum OutputFormat {
    case flag
    case basic
    case detailed
    case verbose
  }

}

extension Schema.Validator.OutputFormat: Sendable {}
extension Schema.Validator.OutputFormat: Hashable {}
extension Schema.Validator.OutputFormat: Equatable {}
