//
//  Schema-AnnotationBehavior.swift
//  SolidFoundation
//
//  Created by Kevin Wooten on 2/20/25.
//

extension Schema {

  public protocol AnnotationBehavior: KeywordBehavior {
    func annotate(context: inout Validator.Context) -> Value?
  }

}

extension Schema.AnnotationBehavior {

  public func prepare(parent: Schema.SubSchema, context: inout Schema.Builder.Context) throws {}

  public func apply(instance: Value, context: inout Schema.Validator.Context) -> Schema.Validation {
    guard let validation = annotate(context: &context) else {
      return .valid
    }
    return .annotation(validation)
  }

}
