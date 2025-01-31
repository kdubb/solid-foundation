//
//  PathQuery-Execute.swift
//  Codex
//
//  Created by Kevin Wooten on 1/30/25.
//

internal extension PathQuery {

  struct Context {

    var root: Value
    var current: Result
    var delegate: Delegate? = nil
    var functions: [String: Function] = standardFunctions.reduce(into: [:]) { $0[$1.name] = $1 }

    func rootContext() -> Self {
      var copy = self
      copy.current = .value(root)
      return copy
    }

    func withCurrent(_ value: Value) -> Self {
      var copy = self
      copy.current = .value(value)
      return copy
    }

    func withCurrent(_ result: Result) -> Self {
      var copy = self
      copy.current = result
      return copy
    }

    func withFunctions(_ functions: [Function]) -> Self {
      var copy = self
      for function in functions {
        copy.functions[function.name] = function
      }
      return copy
    }

  }

  static func query(segments: [Path.Segment], context ctx: Context) -> Result {

    var currentResult: Result = ctx.current

    for segment in segments {

      switch segment {

      case .child(let selectors):
        currentResult = selectChildren(of: selectors, context: ctx.withCurrent(currentResult))

      case .descendant(let selectors):
        currentResult = selectDescendants(of: selectors, context: ctx.withCurrent(currentResult))
      }
    }

    return currentResult
  }

  static func selectChildren(of selectors: [Path.Selector], context ctx: Context) -> Result {

    var result: Result = .nothing

    for selector in selectors {
      let selectorResult = select(selector: selector, context: ctx)
      result = result.joining(selectorResult)
    }

    return result
  }

  static func selectDescendants(of selectors: [Path.Selector], context ctx: Context) -> Result {

    var result: Result = .empty

    let children = selectChildren(of: selectors, context: ctx)
    result = result.joining(children)

    for child in ctx.current.children {
      let descendants = selectDescendants(of: selectors, context: ctx.withCurrent(child))
      result = result.joining(descendants)
    }

    return result
  }

  static func select(selector: Path.Selector, context ctx: Context) -> Result {

    switch selector {

    case .name(let name):
      return selectName(name, context: ctx)

    case .wildcard:
      return selectWildcard(context: ctx)

    case .index(let index):
      return selectIndex(index, context: ctx)

    case .slice(let slice):
      return selectSlice(slice, context: ctx)

    case .filter(let filter):
      return selectFilter(filter, context: ctx)
    }
  }

  static func selectName(_ name: String, context ctx: Context) -> Result {

    guard case .value(.object(let object)) = ctx.current else {
      return .nothing
    }

    return .value(object[.string(name)])
  }

  static func selectWildcard(context ctx: Context) -> Result {
    switch ctx.current {
    case .value(.object(let object)):
      return .nodelist(Array(object.values))
    case .value(.array(let array)):
      return .nodelist(array)
    default:
      return .nothing
    }
  }

  static func selectIndex(_ index: Int, context ctx: Context) -> Result {
    guard
      case .nodelist(let nodes) = selectSlice(.init(start: index, end: index + 1, step: 1), context: ctx),
      let value = nodes.first
    else {
      return .nothing
    }

    return .value(value)
  }

  static func selectSlice(_ slice: Path.Selector.Slice, context ctx: Context) -> Result {

    guard case .value(.array(let array)) = ctx.current else {
      return .nodelist([])
    }

    let step = slice.step ?? 1
    let start = slice.start ?? (step >= 0 ? 0 : array.count - 1)
    let end = slice.end ?? (step >= 0 ? array.count : -array.count - 1)
    let (lower, upper) = bounds(start, end, step, array.count)

    var selected: Value.Array = []
    if step > 0 {
      var i = lower
      while i < upper {
        selected.append(array[i])
        i += step
      }
    }
    else {
      var i = upper
      while lower < i {
        selected.append(array[i])
        i += step
      }
    }

    return .nodelist(selected)

    func bounds(_ start: Int, _ end: Int, _ step: Int, _ len: Int) -> (Int, Int) {
      let nStart = normalize(start, len)
      let nEnd = normalize(end, len)

      if step >= 0 {
        let lower = min(max(nStart, 0), len)
        let upper = min(max(nEnd, 0), len)
        return (lower, upper)
      }
      else {
        let upper = min(max(nStart, -1), len - 1)
        let lower = min(max(nEnd, -1), len - 1)
        return (lower, upper)
      }
    }

    func normalize(_ i: Int, _ len: Int) -> Int {
      if i >= 0 {
        return i
      }
      else {
        return len + i
      }
    }
  }

  static func selectFilter(_ filter: Path.Selector.Expression, context ctx: Context) -> Result {

    let children = ctx.current.children

    guard !children.isEmpty else {
      return .empty
    }

    var selected: [Value] = []
    for child in children {

      switch evaluateExpression(filter, context: ctx.withCurrent(child)) {

      case .value(.bool(let value)) where value == true:
        selected.append(child)

      case .nodelist(let values) where !values.isEmpty:
        selected.append(contentsOf: values)

      default:
        continue
      }
    }

    return .nodelist(selected)
  }

  static func evaluateExpression(_ expression: Path.Selector.Expression, context ctx: Context) -> Result {
    return switch expression {
    case .singularQuery(segments: let segments, type: let type):
      querySingular(segments, type: type, context: ctx)

    case .query(segments: let segments, type: let type):
      query(segments, type: type, context: ctx)

    case .logical(operator: let op, expressions: let expressions):
      evaluateLogical(op, expressions: expressions, context: ctx)

    case .comparison(left: let left, operator: let op, right: let right):
      evaluateComparison(op, left: left, right: right, context: ctx)

    case .test(expression: let expression, negated: let negated):
      evaluateTest(expression, negated: negated, context: ctx)

    case .function(name: let name, arguments: let arguments):
      evaluateFunction(name, argumentExpressions: arguments, context: ctx)

    case .literal(let value):
        .value(value)
    }
  }

  static func evaluateTest(_ test: Path.Selector.Expression, negated: Bool, context ctx: Context) -> Result {

    let result = evaluateExpression(test, context: ctx)
    switch test {

    case .query, .singularQuery:
      // Test if there are any results
      let value = result.values.isEmpty == (negated ? true : false)
      return .value(.bool(value))

    case .function:
      switch result {
      case .value(.bool(let value)):
        return .value(.bool(negated ? value == false : value == true))
      case .nodelist(let list):
        return .value(.bool(negated ? list.isEmpty : !list.isEmpty))
      default:
        return .nothing
      }

    default:
      return .nothing
    }
  }

  static func querySingular(
    _ segments: [Path.Segment],
    type: Path.Selector.Expression.QueryType,
    context ctx: Context
  ) -> Result {
    // Parser should have ensured that there is a single result query
    return query(segments, type: type, context: ctx)
  }

  static func query(
    _ segments: [Path.Segment],
    type: Path.Selector.Expression.QueryType,
    context ctx: Context
  ) -> Result {
    if type == .absolute {
      return query(segments: segments, context: ctx.rootContext())
    } else {
      return query(segments: segments, context: ctx)
    }
  }

  static func evaluateLogical(
    _ op: Path.Selector.Expression.LogicalOperator,
    expressions: [Path.Selector.Expression],
    context ctx: Context
  ) -> Result {

    switch op {

    case .and:

      let pass = expressions.lazy
        .map { evaluateExpression($0, context: ctx) }
        .allSatisfy { $0 == .value(.bool(true)) }

      return .value(.bool(pass))

    case .or:

      let pass = expressions.lazy
        .map { evaluateExpression($0, context: ctx) }
        .contains { $0 == .value(.bool(true)) }

      return .value(.bool(pass))

    case .not:

      guard
        let expression = expressions.first,
        case .value(.bool(let boolVal)) = selectFilter(expression, context: ctx)
      else {
        return .nothing
      }

      return .value(.bool(!boolVal))
    }
  }

  static func evaluateComparison(
    _ op: Path.Selector.Expression.ComparisonOperator,
    left: Path.Selector.Expression,
    right: Path.Selector.Expression,
    context ctx: Context
  ) -> Result {

    let l = evaluateExpression(left, context: ctx)
    let r = evaluateExpression(right, context: ctx)

    switch op {
    case .eq:
      return .value(.bool(evaluateEqual(l, r)))
    case .ne:
      return .value(.bool(evaluateEqual(l, r) == false))
    case .lt:
      return .value(.bool(evaluateLessThan(l, r)))
    case .le:
      return .value(.bool(evaluateLessThan(l, r) || evaluateEqual(l, r)))
    case .gt:
      return .value(.bool(evaluateLessThan(r, l)))
    case .ge:
      return .value(.bool(evaluateLessThan(r, l) || evaluateEqual(l, r)))
    }
  }

  static func evaluateEqual(_ l: Result, _ r: Result) -> Bool {
    switch (l.comparable(), r.comparable()) {
    case (.nothing, .nothing), (.nothing, .nodelist([])), (.nodelist([]), .nothing):
      return true
    case (.value(let lVal), .value(let rVal)):
      return lVal == rVal
    case (.nodelist(let lVal), .nodelist(let rVal)):
      return lVal == rVal
    default:
      return false
    }
  }

  static func evaluateLessThan(_ l: Result, _ r: Result) -> Bool {
    switch (l.comparable(), r.comparable()) {
    case (.nothing, _), (_, .nothing), (.nodelist([]), _), (_, .nodelist([])):
      return false
    case (.value(.number(let lVal)), .value(.number(let rVal))):
      return lVal.decimal < rVal.decimal
    case (.value(.string(let lVal)), .value(.string(let rVal))):
      return lVal < rVal
    default:
      return false
    }
  }

  static func evaluateFunction(
    _ name: String,
    argumentExpressions: [Path.Selector.Expression],
    context ctx: Context
  ) -> Result {

    guard let function = ctx.functions[name] else {
      return .nothing
    }

    var arguments: [Function.Argument] = []

    for (argumentIndex, argumentType) in function.arguments.enumerated() {

      let argumentResult = evaluateExpression(argumentExpressions[argumentIndex], context: ctx)
      switch (argumentType, argumentResult) {

      case (.value, .value(let value)):
        arguments.append(.value(value))

      case (.logical, .value(.bool(let value))):
        arguments.append(.logical(value))

      case (.logical, .nodelist(let nodes)):
        arguments.append(.logical(!nodes.isEmpty))

      case (.nodes, .nodelist(let nodes)):
        arguments.append(.nodes(nodes))

      default:

        ctx.delegate?.functionArgumentTypeMismatch(
          function: function,
          argumentIndex: argumentIndex,
          expectedType: argumentType,
          actual: argumentResult.argument()
        )

        return .nothing
      }
    }

    return switch function.execute(arguments) {
    case .nothing:
        .nothing
    case .value(let value):
        .value(value)
    case .logical(let value):
        .value(.bool(value))
    case .nodes(let nodes):
        .nodelist(nodes)
    }
  }

}

private extension PathQuery.Result {

  func comparable() -> Self {
    guard case .nodelist(let list) = self, list.count == 1 else {
      return self
    }
    return .value(list[0])
  }

  func argument() -> PathQuery.Function.Argument {
    switch self {
    case .nothing:
      return .nothing
    case .value(let value):
      return .value(value)
    case .nodelist(let list):
      return .nodes(list)
    }
  }
  var children: [Value] {
    switch self {
    case .value(.object(let object)):
      return Array(object.values)
    case .value(.array(let array)):
      return array
    case .nodelist(let list):
      return list
    default:
      return []
    }
  }

  func joining(_ result: Self) -> Self {
    switch (self, result) {
    case (.nothing, .nothing):
      return .nothing
    case (.nothing, .value(let value)), (.value(let value), .nothing):
      return .value(value)
    case (.nothing, .nodelist(let list)), (.nodelist(let list), .nothing):
      return .nodelist(list)
    case (.value(let l), .value(let r)):
      return .nodelist([l, r])
    case (.value(let l), .nodelist(let r)):
      return .nodelist([l] + r)
    case (.nodelist(let l), .value(let r)):
      return .nodelist(l + [r])
    case (.nodelist(let l), .nodelist(let r)):
      return .nodelist(l + r)
    }

  }
}
