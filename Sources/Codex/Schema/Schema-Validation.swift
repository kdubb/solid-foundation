//
//  Schema-Validation.swift
//  Codex
//
//  Created by Kevin Wooten on 2/24/25.
//

extension Schema {

  public enum Validation {
    case valid
    case annotation(Value)
    case invalid(String?)

    public static var invalid: Validation { .invalid(nil) }

    public var isValid: Bool {
      switch self {
      case .valid, .annotation:
        return true
      default:
        return false
      }
    }
  }

}

extension Schema.Validation: Sendable {}
extension Schema.Validation: Equatable {}
extension Schema.Validation: Hashable {}
