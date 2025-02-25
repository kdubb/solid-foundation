//
//  Schema-AssertionBehavior.swift
//  Codex
//
//  Created by Kevin Wooten on 2/8/25.
//

extension Schema {

  public enum Assertion {
    case valid
    case invalid(_ message: String)

    public static func invalid(requiredType: Schema.InstanceType) -> Self {
      .invalid("Must be of type '\(requiredType)'")
    }
    
    public static func invalid<S: Collection, T: CustomStringConvertible>(options: S) -> Self where S.Element == T {
      return .invalid(options.joinedToList(prefix: "Must be one of"))
    }
  }

  public protocol AssertionBehavior: KeywordBehavior {
    func assert(instance: Value, context: inout Validator.Context) -> Assertion
  }

}

extension Schema.Assertion: Sendable {}
extension Schema.AssertionBehavior {

  public func prepare(parent: any Schema.SubSchema, context: inout Schema.Builder.Context) throws {}

  public func apply(instance: Value, context: inout Schema.Validator.Context) -> Schema.Validation {
    let assertion = assert(instance: instance, context: &context)
    switch assertion {
    case .valid:
      return .valid
    case .invalid(let message):
      return .invalid(message)
    }
  }

}
