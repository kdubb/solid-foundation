//
//  Schema-Validator-VerboseResult.swift
//  Codex
//
//  Created by Kevin Wooten on 2/8/25.
//

extension Schema.Validator {

  public struct VerboseResult: Result {

    public struct Builder: Context.ResultBuilder {

      public let detailsOnly: Bool
      public var resultsStack: [[VerboseResult]] = [[]]

      public init(detailsOnly: Bool) {
        self.detailsOnly = detailsOnly
      }

      public var current: [VerboseResult] {
        get {
          guard !resultsStack.isEmpty else {
            fatalError("Results stack is empty")
          }
          return resultsStack[resultsStack.count - 1]
        }
        set {
          guard !resultsStack.isEmpty else {
            fatalError("Results stack is empty")
          }
          resultsStack[resultsStack.count - 1] = newValue
        }
      }

      public mutating func push() {
        resultsStack.append([])
      }

      public mutating func add(validation: Schema.Validation, in scope: Context.Scope) {
        let result = self.result(validation: validation, scope: scope, results: [])
        current.append(result)
      }

      public mutating func pop(validation: Schema.Validation, in scope: Context.Scope) -> VerboseResult {
        let result = self.result(validation: validation, scope: scope, results: resultsStack.removeLast())
        add(result, scope: scope)
        return result
      }

      public func result(
        validation: Schema.Validation,
        scope: Context.Scope,
        results: [VerboseResult]
      ) -> VerboseResult {
        return VerboseResult(
          validation: validation,
          instanceLocation: scope.instanceLocation,
          keywordLocation: scope.keywordLocation,
          absoluteKeywordLocation: Self.buildAbsoluteKeywordLocation(scope: scope),
          results: results
        )
      }

      mutating func add(_ result: VerboseResult, scope: Context.Scope) {
        guard detailsOnly else {
          current.append(result)
          return
        }

        switch result.results.count {
        case 0 where !result.isValid:
          current.append(result)
        case 0:
          break
        case 1:
          current.append(result.results[0])
        default:
          current.append(result)
        }
      }

      static func buildAbsoluteKeywordLocation(scope: Context.Scope) -> URI? {
        let keywordLocation = scope.keywordLocation
        if keywordLocation.hasRefKeyword {
          let id = scope.id ?? scope.baseId
          return id.appending(fragmentPointer: scope.absoluteKeywordLocation)
        } else if let id = scope.id, id != scope.baseId {
          return id.appending(fragmentPointer: scope.absoluteKeywordLocation)
        }
        return nil
      }

    }

    public var isValid: Bool { validation.isValid }

    public let validation: Schema.Validation
    public let instanceLocation: Pointer
    public let keywordLocation: Pointer
    public let absoluteKeywordLocation: URI?
    public var results: [VerboseResult]
  }

}

extension Schema.Validator.VerboseResult: Sendable {}

extension Schema.Validator.VerboseResult: CustomStringConvertible {

  public var description: String {
    let entry =
      switch validation {
      case .valid: ""
      case .invalid(let error): error.map { "\nerror: \($0)" }
      case .annotation(let ann): "\nannotation: \(ann)"
      }
    let parent = [
      "\(isValid ? "✓ valid" : "✘ invalid")",
      "keywordLocation: \(keywordLocation == .root ? "''" : keywordLocation.description)",
      absoluteKeywordLocation.map { "absoluteKeywordLocation: '\($0)'" },
      "instanceLocation: \(instanceLocation == .root ? "''" : instanceLocation.description)",
      entry,
    ]
    .compactMap(\.self).joined(separator: "\n")
    let children =
      if results.isEmpty {
        ""
      } else {
        results.map { "\n->  \($0.description.split(separator: "\n").joined(separator: "\n    "))" }
          .joined(
            separator: ""
          )
      }
    return "\(parent)\(children)"
  }

}

private extension Schema.Validator.Context.Scope {

  var isCurrentKeywordApplicator: Bool {
    guard let currentKeyword else {
      return false
    }
    return metaSchema.applicatorKeywords.contains(currentKeyword)
  }

  var currentKeyword: Schema.Keyword? {
    relativeKeywordTokens.last { $0 is Schema.Keyword } as? Schema.Keyword
  }

}
