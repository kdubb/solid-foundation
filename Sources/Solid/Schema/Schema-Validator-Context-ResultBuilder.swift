//
//  Schema-Validator-Context-ResultBuilder.swift
//  SolidFoundation
//
//  Created by Kevin Wooten on 2/8/25.
//

extension Schema.Validator.Context {

  public protocol ResultBuilder: Sendable {

    associatedtype ResultType: Schema.Validator.Result

    mutating func push()

    mutating func add(validation: Schema.Validation, in scope: Schema.Validator.Context.Scope)

    @discardableResult
    mutating func pop(validation: Schema.Validation, in scope: Schema.Validator.Context.Scope) -> ResultType

  }

  public typealias AnyResultBuilder = any ResultBuilder

}
