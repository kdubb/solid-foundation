//
//  Path-Query-Delegate.swift
//  SolidFoundation
//
//  Created by Kevin Wooten on 1/30/25.
//

extension Path.Query {

  /// Delegate for query evaulation events.
  ///
  /// ``Path`` instances are validated during initialization but some
  /// errors can only be detected at runtime, like function argument type
  /// mismatches. An instance of this delegate can be provided when executing
  /// queries to be notified of these errors.
  ///
  /// Reports:
  /// - Function evaluation errors
  /// - Function argument type mismatches
  ///
  /// - SeeAlso:
  ///   - ``Path``
  ///   - ``Path/Query``
  ///   - ``Function``
  ///
  public protocol Delegate {

    /// Notification of a function argument type mismatch.
    ///
    /// This is called when a Path query function is called with an argument that is not
    /// of the expected type.
    ///
    /// - Parameters:
    ///   - function: The function that was evaluated.
    ///   - argumentIndex: The index of the argument that was mismatched.
    ///   - expectedType: The expected type of the argument.
    ///   - actual: The actual value of the argument.
    func functionArgumentTypeMismatch(
      function: Path.Function,
      argumentIndex: Int,
      expectedType: Path.Function.ArgumentType,
      actual: Path.Function.Argument
    )

    /// Notification of a function evaluation failure.
    ///
    /// This is called when a Path query function throws an error or
    /// otherwise fails to evaluate due to an error.
    ///
    /// - Parameters:
    ///   - function: The function that was evaluated.
    ///   - arguments: The arguments that were passed to the function.
    ///   - error: The error that occurred during evaluation, or `nil` if the error is not known.
    func functionEvaluationFailed(function: Path.Function, arguments: [Path.Function.Argument], error: Swift.Error?)
  }

}

extension Path.Query.Delegate {

  /// Default implementation of
  /// ``PathQuery/Delegate-swift.protocol/functionArgumentTypeMismatch(function:argumentIndex:expectedType:actual:)-73ufb``.
  ///
  public func functionArgumentTypeMismatch(
    function: Path.Function,
    argumentIndex: Int,
    expectedType: Path.Function.ArgumentType,
    actual: Path.Function.Argument
  ) {
  }

  /// Default implementation of ``PathQuery/Delegate-swift.protocol/functionEvaluationFailed(function:arguments:error:)-lgs``.
  ///
  public func functionEvaluationFailed(
    function: Path.Function,
    arguments: [Path.Function.Argument],
    error: Error?
  ) {
  }
}
