//
//  Schema-AnyKeywordBehavior.swift
//  SolidFoundation
//
//  Created by Kevin Wooten on 2/20/25.
//

extension Schema {

  /// Type erased ``KeywordBehavior`` implementation for any keyword.
  public struct AnyKeywordBehavior: KeywordBehavior {

    public let wrapped: KeywordBehavior

    public init(_ wrapped: KeywordBehavior) {
      self.wrapped = wrapped
    }

    public var keyword: Keyword { wrapped.keyword }

    public func prepare(parent: SubSchema, context: inout Builder.Context) throws {
      // try wrapped.prepare(parent: parent, context: &context)
    }

    public func apply(instance: Value, context: inout Validator.Context) -> Validation {
      wrapped.apply(instance: instance, context: &context)
    }
  }

}
