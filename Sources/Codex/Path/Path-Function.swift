//
//  Path-Query-Function.swift
//  Codex
//
//  Created by Kevin Wooten on 1/30/25.
//

extension Path {

  /// Defininition of a ``Path`` function extension.
  ///
  /// ``Path`` filters expressions can be extended with custom functionality by
  /// registering functions that can be called by name during query evaluation.
  /// Function extensions are registered names that can be applied to zero or more
  /// arguments to produce a result.
  ///
  /// The ``JSONPath`` specification defines a set of built-in functions (e.g., ``length``,
  /// ``count``) that are always available. This implementation provides additional
  /// built-in functions (e.g., ``key``, ``join``) for enhanced functionality. Finally,
  /// users can define their own functions to extend the functionality of ``Path``
  /// as needed.
  ///
  /// # Function Arguments and Results
  /// Functions take a zero or more arguments and return a single argument.
  ///
  /// Functions arguments and results can be any of the following types:
  /// - ``Logical`` - A boolean value that can affect the current evaluation flow.
  /// - ``Value`` - An instance of a ``Value`` and the normalized ``Path`` to the
  /// instance, if known.
  /// - ``Nodes`` - A list of ``Path/Query/Node``s, equivalent to a ``Path/Query/NodeList``.
  ///
  /// > SeeAlso:
  /// >  - ``Path/Function/Argument``
  ///
  /// # Function Implementations
  /// Functions are implemented by providing a closure that receives an array of parameters
  /// and returns the function's result.
  ///
  /// Example:
  /// ```swift
  /// let function = Path.function(
  ///  name: "echo",
  ///  arguments: [.value],
  ///  execute: { args in
  ///   guard case let .value(value) = args[0] else {
  ///     return .nothing
  ///   }
  ///   return value
  /// }
  /// ```
  ///
  /// ## Argument Validation
  /// The types of the parameters are validated according to the function's definition prior
  /// to execution and the result is validated to match the function's return type after
  /// execution.
  ///
  /// # Execution
  /// Functions are executed in the context of the current evaluation state and **must** be
  /// free from side effects.  To help ensure this, functions are not provided any contextual
  /// information aside from the arguments passed to them.  This means that functions cannot
  /// access the current evaluation state or any other context information.
  ///
  /// - SeeAlso
  ///   - ``Path/Query/Context``
  ///   - ``Path/Query/Result/function(_:arguments:execute:)``
  ///
  public struct Function {

    /// The type of a function argument.
    ///
    /// A function argument can be one of the following types:
    /// - ``logical`` - A boolean value distinct from booleans contained in ``Value``s.
    /// - ``value`` - An instance of ``Value`` and, if known, the normalized ``Path`` to the instance.
    /// - ``nodes`` - A list of ``Path/Query/Node`` values each containing a ``Value`` and  normalized ``Path``.
    ///
    public enum ArgumentType {

      /// `Logical Type` - A distinct boolean value.
      ///
      /// Logical values are a distinctly different type from booleans contained
      /// in ``Value``s. Logical values can be used to affect the query evaluation.
      ///
      /// > Warning: Due to fact that ``Logical`` values are a distinct type from
      /// > booleans contained in ``Value`` instances, passing a ``Value/bool(_:)``
      /// > to a function that accepts a ``logical`` argument will result in a type
      /// > error.
      ///
      case logical

      /// `Value Type` - An instance of ``Value``.
      ///
      /// Values allow any JSON-like value to be passed to and/or returned from
      /// ``Path`` functions. If the value is locatable by path traversal, the
      /// normalized ``Path`` to the instance is provided.
      ///
      case value

      /// `Nodes Type` - A list of ``Path/Query/Node``s.
      ///
      /// A ``Path/Query/Node`` is a ``Value`` instance along with the
      /// normalized ``Path`` to the instance.
      ///
      case nodes
    }

    /// Instance of a function argument.
    ///
    /// An instance of a function argument which can be one of the following:
    /// - ``nothing`` - No or incorrect value provided.
    /// - ``logical(_:)`` - Instance of ``ArgumentType/logical``.
    /// - ``value(_:path:)`` - Instnace of ``ArgumentType/value``.
    /// - ``nodes(_:)`` - Instance of ``ArgumentType/nodes``.
    ///
    public enum Argument {

      /// No, or an incorrect, value provided.
      ///
      /// Signifies that no value was provided to or returned from the function. It is also
      /// used to indicate that a value of the incorrect type was provided to or returned
      /// from a function.
      ///
      case nothing

      /// ``Path/Function/ArgumentType/logical`` boolean value.
      ///
      case logical(Bool)

      /// ``Path/Function/ArgumentType/value`` instance.
      ///
      /// If the value is reachable by traversing a path from the query argument,
      /// the ``Path`` to the value is provided. If the value is calculated or otherwise
      /// transient, the ``Path`` is `nil`.
      ///
      /// > Note: When returning a value from a function implementation, if the ``Path``
      /// > is known, it _should_ be provided. If the value is transient, or the path is not known,
      /// > the ``Path`` should be `nil`.
      ///
      case value(Value, path: Path? = nil)

      /// ``Path/Function/ArgumentType/nodes`` list.
      ///
      /// List of ``Path/Query/Node`` each containing a ``Value`` and ``Path``
      /// instance. Unlike ``value(_:path:)``, the ``Path`` is always provided
      /// for each node in the list.
      ///
      case nodes([Path.Query.Node])

      /// Constant that represents the empty set of nodes.
      ///
      public static let empty: Argument = .nodes([])
    }

    /// The name of the function.
    ///
    public let name: String

    /// Definitions of the arguments the function accepts.
    ///
    public let arguments: [ArgumentType]

    /// Function's result type.
    ///
    public let result: ArgumentType

    /// The function implementation.
    ///
    public let execute: @Sendable ([Argument]) throws -> Argument

    fileprivate init(
      name: String,
      arguments: [ArgumentType],
      result: ArgumentType,
      execute: @Sendable @escaping ([Argument]) throws -> Argument
    ) {
      self.name = name
      self.arguments = arguments
      self.result = result
      self.execute = execute
    }

  }

  /// Function factory to define new functions.
  ///
  /// Defines a new function with the given name, arguments and implementation.
  ///
  /// - Parameters:
  ///   - name: The name of the function.
  ///   - arguments: The definitions of the arguments the function accepts.
  ///   - result: The function's result type.
  ///   - execute: The function implementation.
  /// - Returns: A new function with the given name, arguments and implementation.
  ///
  public static func function(
    name: String,
    arguments: Function.ArgumentType...,
    result: Function.ArgumentType,
    execute: @Sendable @escaping ([Function.Argument]) throws -> Function.Argument
  ) -> Function {
    function(name: name, arguments: arguments, result: result, execute: execute)
  }

  /// Function factory to define new functions.
  ///
  /// Defines a new function with the given name, arguments and implementation.
  ///
  /// - Parameters:
  ///   - name: The name of the function.
  ///   - arguments: The definitions of the arguments the function accepts.
  ///   - result: The function's return type.
  ///   - execute: The function implementation.
  /// - Returns: A new function with the given name, arguments and implementation.
  ///
  public static func function(
    name: String,
    arguments: [Function.ArgumentType],
    result: Function.ArgumentType,
    execute: @Sendable @escaping ([Function.Argument]) throws -> Function.Argument
  ) -> Function {
    return Function(name: name, arguments: arguments, result: result, execute: execute)
  }

}

extension Path.Function: Sendable {}

extension Path.Function: Hashable {

  /// Hashes the essential components of the function.
  ///
  /// - Parameter hasher: The hasher to use for hashing the components.
  ///
  public func hash(into hasher: inout Hasher) {
    hasher.combine(name)
    hasher.combine(arguments)
  }

}

extension Path.Function: Equatable {

  /// Compares two functions for equality.
  ///
  /// - Parameters:
  ///   - lhs: The left-hand side function to compare.
  ///   - rhs: The right-hand side function to compare.
  /// - Returns: A boolean indicating whether the two functions are equal.
  ///
  public static func == (lhs: Path.Function, rhs: Path.Function) -> Bool {
    lhs.name == rhs.name && lhs.arguments == rhs.arguments
  }

}


extension Path.Function.Argument: Sendable {}

extension Path.Function.Argument: Hashable {

  /// Hashes the essential components of the argument.
  ///
  /// - Parameter hasher: The hasher to use for hashing the components.
  ///
  public func hash(into hasher: inout Hasher) {
    switch self {
    case .nothing:
      hasher.combine(Int.max)
    case .logical(let bool):
      hasher.combine(bool)
    case .value(let value, path: let path):
      hasher.combine(value)
      hasher.combine(path)
    case .nodes(let list):
      for node in list {
        hasher.combine(node)
      }
    }
  }

}

extension Path.Function.Argument: Equatable {

  /// Compares two arguments for equality.
  ///
  /// - Parameters:
  ///   - lhs: The left-hand side argument to compare.
  ///   - rhs: The right-hand side argument to compare.
  /// - Returns: A boolean indicating whether the two arguments are equal.
  ///
  public static func == (lhs: Path.Function.Argument, rhs: Path.Function.Argument) -> Bool {
    switch (lhs, rhs) {
    case (.nothing, .nothing): true
    case (.logical(let lbool), .logical(let rbool)): lbool == rbool
    case (.value(let lval, _), .value(let rval, _)): lval == rval
    case (.nodes(let lnodes), .nodes(let rnodes)): lnodes.map(\.value) == rnodes.map(\.value)
    default: false
    }
  }

}


extension Path.Function.ArgumentType: Sendable {}

extension Path.Function.ArgumentType: Hashable {}
extension Path.Function.ArgumentType: Equatable {}
