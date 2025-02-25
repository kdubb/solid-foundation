//
//  Schema-BuildableKeywordBehavior.swift
//  Codex
//
//  Created by Kevin Wooten on 2/24/25.
//

extension Schema {

  public protocol BuildableKeywordBehavior: KeywordBehavior, KeywordBehaviorBuilder {

    static func build(from keywordInstance: Value, context: inout Builder.Context) throws -> Self?

  }

}

extension Schema.BuildableKeywordBehavior {

  public static func build(
    from keywordInstance: Value,
    context: inout Schema.Builder.Context
  ) throws -> Schema.KeywordBehavior? {
    try Self.build(from: keywordInstance, context: &context)
  }

}
