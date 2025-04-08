//
//  Path-Query.swift
//  Codex
//
//  Created by Kevin Wooten on 1/28/25.
//

extension Path {

  /// Path Query Executor.
  ///
  /// Executes ``Path`` queries with configurable options, allowing for
  /// repeated queries with the same options without having to pass them
  /// as parameters.
  ///
  /// - SeeAlso: ``Path``
  public struct Query {

    /// ``Query`` bound to a specific ``Path``.
    ///
    /// A ``Query`` that has been bound to a specific ``Path`` instance. It can be used to
    /// execute the same path query on a different value instances without having to pass the
    /// ``Path`` instance as a parameter.
    ///
    /// - SeeAlso: ``Query``
    /// - SeeAlso: ``Path``
    ///
    public struct Bound {

      /// The query to evaluate.
      public let query: Query

      /// The path to evaluate.
      public let path: Path

      /// Evaluate a value instance.
      ///
      /// Evaluates this ``Query`` and ``Path`` against the provided value instance.
      ///
      /// - Parameter:   - value: The value instance to evaluate the query against.
      /// - Returns: The result of the query evaluation.
      ///
      /// - SeeAlso: ``Query/evaluate(path:against:functions:delegate:)``
      ///
      public func evaluate(against value: Value) -> NodeList {
        return query.evaluate(path: path, against: value)
      }

    }

    /// The functions to use in query evaluations.
    ///
    /// These are the external functions that will be available to the path query during
    /// evaluation. This property does not include the functions defined by `JSONPath` nor
    /// those provided by the ``Path`` library itself.
    ///
    /// - SeeAlso: ``Path/Function``
    public var functions: [Path.Function] = []

    /// Optional delegate for notification of runtime path errors.
    ///
    /// This delegate will be notified of runtime errors that occur during the evaluation of
    /// the path query.
    ///
    /// - SeeAlso: ``Path/Delegate``
    public var delegate: Delegate?

    /// Initialize a path query with custom functions and an optional delegate.
    ///
    /// - Parameters:
    ///   - functions: The functions to use in the query.
    ///   - delegate: The delegate to notify of path events.
    public init(functions: [Function], delegate: Delegate? = nil) {
      self.functions = functions
      self.delegate = delegate
    }

    /// Evaluate the query.
    ///
    /// Evaluates the provided path against the provided value instance, using this
    /// query's configurations.
    ///
    /// - Parameters:
    ///   - path: The path to query.
    ///   - value: The value to query.
    /// - Returns: The result of the path evaluation.
    ///
    /// - SeeAlso: ``Query/evaluate(path:against:functions:delegate:)``
    public func evaluate(path: Path, against value: Value) -> NodeList {
      let context =
        Context(
          root: value,
          current: [(value, .root)],
          delegate: delegate,
          functions: allFunctions
        )
      return Path.Query.evaluate(segments: path.segments, context: context)
    }

    internal var allFunctions: [String: Path.Function] {
      (Self.builtInFunctions + functions)
        .reduce(into: [:]) { result, function in
          result[function.name] = function
        }
    }

    /// Evaluate a provided path query.
    ///
    /// Utility function for evaluating a path query without having to create a
    /// ``Query`` instance.
    ///
    /// - Parameters:
    ///   - path: The path to evaluate.
    ///   - value: The value instance to evaluate the path against.
    ///   - functions: The externally defined functions to use in the evaluation.
    ///   - delegate: The delegate used for path evaluation events.
    /// - Returns: The result of the path evaluation.
    ///
    /// - SeeAlso: ``Query/evaluate(path:from:functions:delegate:)``
    public static func evaluate(
      path: Path,
      against value: Value,
      functions: [Path.Function] = [],
      delegate: Delegate? = nil
    ) -> NodeList {
      Path.Query(functions: functions, delegate: delegate)
        .evaluate(path: path, against: value)
    }
  }
}

extension Path.Query {

  /// All built-in functions.
  ///
  /// These are the functions either defined by `JSONPath` or provided by the ``Path`` library
  /// itself. They are available for use in path queries without having to be explicitly
  /// added to the ``Query`` instance.
  ///
  public static let builtInFunctions: [Path.Function] = [
    Path.BuiltInFunctions.length,
    Path.BuiltInFunctions.count,
    Path.BuiltInFunctions.match,
    Path.BuiltInFunctions.search,
    Path.BuiltInFunctions.value,
    Path.BuiltInFunctions.key,
  ]

}
