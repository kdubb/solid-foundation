//
//  Path-Selector-Expression.swift
//  Codex
//
//  Created by Kevin Wooten on 1/28/25.
//

extension Path.Selector {

  public indirect enum Expression {

    public enum LogicalOperator: String {
      case and = "&&"
      case or = "||"
      case not = "!"
    }

    public enum ComparisonOperator: String {
      case eq = "=="
      case ne = "!="
      case lt = "<"
      case le = "<="
      case gt = ">"
      case ge = ">="
    }

    public enum QueryType {
      case absolute
      case relative
    }

    case literal(Value)
    case singularQuery(segments: [Path.Segment])
    case query(segments: [Path.Segment])
    case function(name: String, arguments: [Expression])
    case logical(operator: LogicalOperator, expressions: [Expression])
    case comparison(left: Expression, operator: ComparisonOperator, right: Expression)
    case test(expression: Expression, negated: Bool = false)
  }

}

extension Path.Selector.Expression.LogicalOperator : Sendable {}
extension Path.Selector.Expression.ComparisonOperator : Sendable {}
extension Path.Selector.Expression.QueryType : Sendable {}
extension Path.Selector.Expression : Sendable {}

extension Path.Selector.Expression : Hashable {}
extension Path.Selector.Expression : Equatable {}

extension Path.Selector.Expression : CustomStringConvertible {

  public var description: String {
    switch self {
    case .literal(let value):
      return "\(value)"
    case .singularQuery(let segments):
      return segments.codexDescription
    case .query(let segments):
      return segments.codexDescription
    case .function(let name, let arguments):
      return "\(name)(\(arguments.map(\.description).joined(separator: ", ")))"
    case .logical(let op, let expressions):
      return expressions.map(\.description).joined(separator: " \(op.rawValue) ")
    case .comparison(let left, let op, let right):
      return "\(left) \(op) \(right)"
    case .test(let expression, let negated):
      return "\(negated ? "!" : "")\(expression)"
    }
  }
}
