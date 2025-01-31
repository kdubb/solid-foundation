//
//  PathQuery-Delegate.swift
//  Codex
//
//  Created by Kevin Wooten on 1/30/25.
//

extension PathQuery {

  public protocol Delegate {

    func functionArgumentTypeMismatch(
      function: Function,
      argumentIndex: Int,
      expectedType: Function.ArgumentType,
      actual: Function.Argument
    )

    func functionEvaluationFailed(function: Function, arguments: [Function.Argument])
  }

}

extension PathQuery.Delegate {

    public func functionArgumentTypeMismatch(
      function: PathQuery.Function,
      argumentIndex: Int,
      expectedType: PathQuery.Function.ArgumentType,
      actual: PathQuery.Function.Argument
    ) {
    }
  
  public func functionEvaluationFailed(function: PathQuery.Function, arguments: [PathQuery.Function.Argument]) {
  }
}

