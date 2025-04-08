//
//  Path-Selector-Expression.swift
//  Codex
//
//  Created by Kevin Wooten on 1/28/25.
//

extension Path.Selector {

  /// Arbitrary expression that can be used to filter values.
  ///
  public indirect enum Expression {

    /// Logical operators available for ``Path/Selector/Expression``.
    ///
    /// - ``and``: Logical AND operator.
    /// - ``or``: Logical OR operator.
    /// - ``not``: Logical NOT operator.
    ///
    public enum LogicalOperator: String {
      case and = "&&"
      case or = "||"
      case not = "!"
    }

    /// Comparison operators available for ``Path/Selector/Expression``.
    ///
    /// - ``eq``: Equal operator.
    /// - ``ne``: Not equal operator.
    /// - ``lt``: Less than operator.
    /// - ``le``: Less than or equal operator.
    /// - ``gt``: Greater than operator.
    /// - ``ge``: Greater than or equal operator.
    ///
    public enum ComparisonOperator: String {
      case eq = "=="
      case ne = "!="
      case lt = "<"
      case le = "<="
      case gt = ">"
      case ge = ">="
    }

    /// Query type for ``Path/Selector/Expression``.
    ///
    /// - ``absolute``: Query that selects values from the root of the document.
    /// - ``relative``: Query that selects values from the current context.
    ///
    public enum QueryType {
      case absolute
      case relative
    }

    /// Literal value expression.
    ///
    /// A `null`, `boolean`, `number`, `string` value.
    ///
    /// - Parameter _: The value to be represented.
    ///
    case literal(Value, quote: Character? = nil)

    /// A query expression that selects a single value.
    ///
    /// - Parameters:
    ///   - node: Identifier of the initial input node for this query.
    ///   - segments: The path segments to be used in the query.
    ///
    case singularQuery(node: Path.Identifier, segments: [Path.Segment])

    /// A query expression that can select multiple values.
    ///
    /// - Parameters:
    ///   - node: Identifier of the initial input node for this query.
    ///   - segments: The path segments to be used in the query.
    ///
    case query(node: Path.Identifier, segments: [Path.Segment])

    /// A function expression used to execute a defined function.
    ///
    /// - Parameters:
    ///   - name: The name of the function to be executed.
    ///   - arguments: The arguments to be passed to the function.
    ///
    case function(name: String, arguments: [Expression])

    /// A logical expression that combines multiple expressions using logical operators.
    ///
    /// - Parameters:
    ///   - operator: The logical operator to be used (e.g., AND, OR).
    ///   - expressions: The expressions to be combined.
    ///
    case logical(operator: LogicalOperator, expressions: [Expression])

    /// A comparison expression that compares two values using a comparison operator.
    ///
    /// - Parameters:
    ///   - left: The left-hand side expression.
    ///   - operator: The comparison operator to be used (e.g., ==, !=, <, >).
    ///   - right: The right-hand side expression.
    ///
    case comparison(left: Expression, operator: ComparisonOperator, right: Expression)

    /// Executes an expression on the current context value.
    ///
    /// - Parameters:
    ///   - expression: The expression to be tested.
    ///   - negated: A boolean indicating whether the test is negated (i.e., checks for absence).
    ///
    case test(expression: Expression, negated: Bool = false)

    /// Parenthesis expression used to group expressions.
    ///
    /// - Note: Only captured if ``Path/ParseOption/captureParentheses`` is enabled.
    ///
    /// - Parameter _: The expression to be grouped.
    ///
    case parenthesis(Expression)
  }

}

extension Path.Selector.Expression.LogicalOperator: Sendable {}
extension Path.Selector.Expression.ComparisonOperator: Sendable {}
extension Path.Selector.Expression.QueryType: Sendable {}
extension Path.Selector.Expression: Sendable {}

extension Path.Selector.Expression: Hashable {

  /// Hashes the essential components of the expression.
  ///
  /// - Note: The ``parenthesis(_:)`` case and `quote` property of ``Path/Selector/Expression/literal(_:quote:)``
  /// are not included in hashing.
  ///
  /// - Parameter hasher: The hasher to use for hashing the expression.
  ///
  public func hash(into hasher: inout Hasher) {
    switch self {
    case .literal(let value, _):
      hasher.combine(0)
      hasher.combine(value)
    case .singularQuery(let nodeId, let segments):
      hasher.combine(1)
      hasher.combine(nodeId)
      hasher.combine(segments)
    case .query(let nodeId, let segments):
      hasher.combine(2)
      hasher.combine(nodeId)
      hasher.combine(segments)
    case .function(let name, let arguments):
      hasher.combine(3)
      hasher.combine(name)
      hasher.combine(arguments)
    case .logical(let op, let expressions):
      hasher.combine(4)
      hasher.combine(op)
      hasher.combine(expressions)
    case .comparison(let left, let op, let right):
      hasher.combine(5)
      hasher.combine(left)
      hasher.combine(op)
      hasher.combine(right)
    case .test(let expression, let negated):
      hasher.combine(6)
      hasher.combine(expression)
      hasher.combine(negated)
    case .parenthesis(let expr):
      expr.hash(into: &hasher)
    }
  }

}

extension Path.Selector.Expression: Equatable {

  /// Compares two expressions for equality.
  ///
  /// - Note: The ``parenthesis(_:)`` case and `quote` propertyof ``Path/Selector/Expression/literal(_:quote:)``
  /// expressions are not considered for equality.
  ///
  /// - Parameters:
  ///   - lhs: The left-hand side expression.
  ///   - rhs: The right-hand side expression.
  /// - Returns: `true` if the expressions are equal, `false` otherwise.
  ///
  public static func == (lhs: Self, rhs: Self) -> Bool {
    switch (lhs, rhs) {
    case (.literal(let lhsValue, _), .literal(let rhsValue, _)):
      lhsValue == rhsValue
    case (.singularQuery(let lhsNode, let lhsSegments), .singularQuery(let rhsNode, let rhsSegments)):
      lhsNode == rhsNode && lhsSegments == rhsSegments
    case (.query(let lhsNode, let lhsSegments), .query(let rhsNode, let rhsSegments)):
      lhsNode == rhsNode && lhsSegments == rhsSegments
    case (.function(let lhsName, let lhsArguments), .function(let rhsName, let rhsArguments)):
      lhsName == rhsName && lhsArguments == rhsArguments
    case (.logical(let lhsOperator, let lhsExpressions), .logical(let rhsOperator, let rhsExpressions)):
      lhsOperator == rhsOperator && lhsExpressions == rhsExpressions
    case (
      .comparison(let lhsLeft, let lhsOperator, let lhsRight),
      .comparison(let rhsLeft, let rhsOperator, let rhsRight)
    ):
      lhsLeft == rhsLeft && lhsOperator == rhsOperator && lhsRight == rhsRight
    case (.test(let lhsExpression, let lhsNegated), .test(let rhsExpression, let rhsNegated)):
      lhsExpression == rhsExpression && lhsNegated == rhsNegated
    case (.parenthesis(let lhsExpression), _):
      lhsExpression == rhs
    case (_, .parenthesis(let rhsExpression)):
      lhs == rhsExpression
    default:
      false
    }
  }

}

extension Path.Selector.Expression: CustomStringConvertible {

  /// A human readable description of the expression.
  ///
  public var description: String {
    switch self {
    case .literal(let value, let quote):
      return "\(quote.map(String.init) ?? "")\(value.stringified)\(quote.map(String.init) ?? "")"
    case .singularQuery(let nodeId, let segments):
      return "\(nodeId.rawValue)\(segments.codexDescription)"
    case .query(let nodeId, let segments):
      return "\(nodeId.rawValue)\(segments.codexDescription)"
    case .function(let name, let arguments):
      return "\(name)(\(arguments.map(\.description).joined(separator: ", ")))"
    case .logical(let op, let expressions):
      return expressions.map(\.description).joined(separator: " \(op.rawValue) ")
    case .comparison(let left, let op, let right):
      return "\(left) \(op.rawValue) \(right)"
    case .test(let expression, let negated):
      return "\(negated ? "!" : "")\(expression)"
    case .parenthesis(let expr):
      return "(\(expr))"
    }
  }
}
