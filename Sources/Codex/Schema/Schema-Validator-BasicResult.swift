//
//  Schema-Validator-BasicResult.swift
//  Codex
//
//  Created by Kevin Wooten on 2/8/25.
//

import Foundation
import OrderedCollections

extension Schema.Validator {

  public struct BasicResult: Result {

    public struct Error {
      public let keywordLocation: Pointer
      public let absoluteKeywordLocation: URI?
      public let instanceLocation: Pointer
      public let error: String

      public init(keywordLocation: Pointer, absoluteKeywordLocation: URI?, instanceLocation: Pointer, error: String) {
        self.keywordLocation = keywordLocation
        self.absoluteKeywordLocation = absoluteKeywordLocation
        self.instanceLocation = instanceLocation
        self.error = error
      }
    }

    public struct Builder: Context.ResultBuilder {

      public var errors: [Error] = []

      public mutating func push() {}

      public mutating func add(validation: Schema.Validation, in scope: Context.Scope) {
        if let error = self.error(validation: validation, in: scope) {
          errors.append(error)
        }
      }

      public mutating func pop(validation: Schema.Validation, in scope: Context.Scope) -> BasicResult {
        add(validation: validation, in: scope)
        return BasicResult(isValid: validation.isValid, errors: errors)
      }

      public func error(validation: Schema.Validation, in scope: Context.Scope) -> Error? {
        guard case .invalid(let error) = validation, let error else {
          return nil
        }
        return Error(
          keywordLocation: scope.keywordLocation,
          absoluteKeywordLocation: VerboseResult.Builder.buildAbsoluteKeywordLocation(scope: scope),
          instanceLocation: scope.instanceLocation,
          error: error
        )
      }
    }

    public let isValid: Bool
    public var errors: [Error]
  }

}

extension Schema.Validator.BasicResult.Error: Sendable {}
extension Schema.Validator.BasicResult.Error: Hashable {}
extension Schema.Validator.BasicResult.Error: Equatable {}

extension Schema.Validator.BasicResult.Error: CustomStringConvertible {

  public var description: String {
    """
    keywordLocation: \(keywordLocation)
    abaoluteKeywordLocation: \(absoluteKeywordLocation?.encoded ?? "''")
    instanceLocation: \(instanceLocation)
    error: \(error)
    """
  }
}


extension Schema.Validator.BasicResult: Sendable {}
extension Schema.Validator.BasicResult: Hashable {}
extension Schema.Validator.BasicResult: Equatable {}

extension Schema.Validator.BasicResult: CustomStringConvertible {

  public var description: String {
    """
    valid: \(isValid)
    errors:\n\(errors.map { " -> \($0.description.split(separator: "\n").joined(separator: "\n    "))" }.joined(separator: "\n"))
    """
  }
}
