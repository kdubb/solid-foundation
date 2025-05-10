//
//  Schema-ReservedBehavior.swift
//  SolidFoundation
//
//  Created by Kevin Wooten on 2/20/25.
//

extension Schema {

  public protocol ReservedBehavior: KeywordBehavior {}

}

extension Schema.ReservedBehavior {

  public func prepare(parent: any Schema.SubSchema, context: inout Schema.Builder.Context) throws {}

  public func apply(instance: Value, context: inout Schema.Validator.Context) -> Schema.Validation {
    return .valid
  }
}
