//
//  Schema-IdentifierBehavior.swift
//  Codex
//
//  Created by Kevin Wooten on 2/20/25.
//

extension Schema {

  public protocol IdentifierBehavior: KeywordBehavior {
    static func process(from keywordInstance: Value, context: inout Builder.Context) throws
  }

}

extension Schema.IdentifierBehavior {

  public var order: Schema.KeywordBehaviorOrder { .identifiers }

  public static func build(from keywordInstance: Value, context: inout Schema.Builder.Context) throws -> Self? {
    try process(from: keywordInstance, context: &context)
    return nil
  }
  
  public func prepare(parent: any Schema.SubSchema, context: inout Schema.Builder.Context) throws {}

  public func apply(instance: Value, context: inout Schema.Validator.Context) -> Schema.Validation {
    return .valid
  }

}
