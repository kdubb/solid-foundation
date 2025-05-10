//
//  Schema-CompositeApplicatorBehavior.swift
//  SolidFoundation
//
//  Created by Kevin Wooten on 2/24/25.
//

extension Schema {

  public protocol CompositeApplicatorBehavior: ApplicatorBehavior {
    var subSchemas: [SubSchema] { get }
    func validations(instance: Value, context: inout Validator.Context) -> [Validation]
    func combine(validations: [Validation], context: inout Validator.Context) -> Validation
  }

}

extension Schema.CompositeApplicatorBehavior {

  public var order: Schema.KeywordBehaviorOrder { .composites }

  public func apply(instance: Value, context: inout Schema.Validator.Context) -> Schema.Validation {
    let validations = self.validations(instance: instance, context: &context)
    return self.combine(validations: validations, context: &context)
  }

  public func validations(instance: Value, context: inout Schema.Validator.Context) -> [Schema.Validation] {
    return subSchemas.enumerated().map { context.validate(instance: .inPlace(instance), using: $1, at: $0) }
  }

}
