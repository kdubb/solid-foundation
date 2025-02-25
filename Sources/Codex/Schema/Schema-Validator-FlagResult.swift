//
//  Schema-Validator-FlagResult.swift
//  Codex
//
//  Created by Kevin Wooten on 2/8/25.
//

extension Schema.Validator {

  public struct FlagResult: Result {

    public struct Builder: Context.ResultBuilder {

      public var results: [[Bool]] = [[]]

      public mutating func push() {
        self.results.append([])
      }

      public mutating func add(validation: Schema.Validation, in scope: Context.Scope) {
        results[results.count - 1].append(validation.isValid)
      }

      public mutating func pop(validation: Schema.Validation, in scope: Context.Scope) -> FlagResult {
        FlagResult(isValid: validation.isValid)
      }
    }

    public let isValid: Bool
    public var error: String? { nil }
    public var errors: [Self] { [] }
  }

}

extension Schema.Validator.FlagResult: Sendable {}

extension Schema.Validator.FlagResult: CustomStringConvertible {

  public var description: String { isValid ? "valid" : "invalid" }

}
