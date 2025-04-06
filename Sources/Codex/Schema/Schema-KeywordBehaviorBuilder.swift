//
//  Schema-KeywordBehaviorBuilder.swift
//  Codex
//
//  Created by Kevin Wooten on 2/20/25.
//

extension Schema {

  /// Builder for a specific ``Schema/KeywordBehavior`` type.
  ///
  public protocol KeywordBehaviorBuilder: Sendable {

    associatedtype Behavior: KeywordBehavior

    static var keyword: Keyword { get }

    static func build(from keywordInstance: Value, context: inout Builder.Context) throws -> Behavior?
  }

}
