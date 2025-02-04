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
      copy.current = .value(root, path: .root)
      return copy
    }

    func withCurrent(_ value: Value, path: Path) -> Self {
      var copy = self
      copy.current = .value(value, path: path)
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

    var currentResult: Result = .nothing

    for segment in segments {

      switch segment {

      case .root:
        currentResult = ctx.rootContext().current

      case .current:
        currentResult = ctx.current

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

    for (childValue, childPath) in ctx.current.children {
      let descendants = selectDescendants(of: selectors, context: ctx.withCurrent(childValue, path: childPath))
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

    guard case .value(.object(let object), let path) = ctx.current else {
      return .nothing
    }

    return .value(object[.string(name)], path: path.appending(name: name))
  }

  static func selectWildcard(context ctx: Context) -> Result {
    switch ctx.current {
    case .value(.object(let object), let path):
      return .nodelist(object.map { ($0.value, path.appending(name: $0.key.stringified)) })
    case .value(.array(let array), let path):
      return .nodelist(array.enumerated().map { (index, value) in (value, path.appending(index: index)) })
    default:
      return .nothing
    }
  }

  static func selectIndex(_ index: Int, context ctx: Context) -> Result {
    guard
      case .nodelist(let nodes) = selectSlice(.init(start: index, end: index + 1, step: 1), context: ctx),
      let (value, path) = nodes.first
    else {
      return .nothing
    }

    return .value(value, path: path)
  }

  static func selectSlice(_ slice: Path.Selector.Slice, context ctx: Context) -> Result {

    guard case .value(.array(let array), let path) = ctx.current else {
      return .nodelist([])
    }

    let step = slice.step ?? 1
    let start = slice.start ?? (step >= 0 ? 0 : array.count - 1)
    let end = slice.end ?? (step >= 0 ? array.count : -array.count - 1)
    let (lower, upper) = bounds(start, end, step, array.count)

    var selected: [(Value, Path)] = []
    if step > 0 {
      var i = lower
      while i < upper {
        selected.append((array[i], path.appending(index: i)))
        i += step
      }
    }
    else {
      var i = upper
      while lower < i {
        selected.append((array[i], path.appending(index: i)))
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

    var selected: [(Value, Path)] = []
    for (childValue, childPath) in children {

      switch evaluateExpression(filter, context: ctx.withCurrent(childValue, path: childPath)) {

      case .value(.bool(let value), _) where value == true:
        selected.append((childValue, childPath))

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
    case .singularQuery(segments: let segments):
      query(segments: segments, context: ctx)

    case .query(segments: let segments):
      query(segments: segments, context: ctx)

    case .logical(operator: let op, expressions: let expressions):
      evaluateLogical(op, expressions: expressions, context: ctx)

    case .comparison(left: let left, operator: let op, right: let right):
      evaluateComparison(op, left: left, right: right, context: ctx)

    case .test(expression: let expression, negated: let negated):
      evaluateTest(expression, negated: negated, context: ctx)

    case .function(name: let name, arguments: let arguments):
      evaluateFunction(name, argumentExpressions: arguments, context: ctx)

    case .literal(let value):
        .value(value, path: .empty)
    }
  }

  static func evaluateTest(_ test: Path.Selector.Expression, negated: Bool, context ctx: Context) -> Result {

    let result = evaluateExpression(test, context: ctx)
    switch test {

    case .query, .singularQuery:
      // Test if there are any results
      let value = result.values.isEmpty == (negated ? true : false)
      return .value(.bool(value), path: .empty)

    case .function:
      switch result {
      case .value(.bool(let value), _):
        return .value(.bool(negated ? value == false : value == true), path: .empty)
      case .nodelist(let list):
        return .value(.bool(negated ? list.isEmpty : !list.isEmpty), path: .empty)
      default:
        return .nothing
      }

    default:
      return .nothing
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
        .allSatisfy { $0.comparable() == .value(.bool(true), path: .empty) }

      return .value(.bool(pass), path: .empty)

    case .or:

      let pass = expressions.lazy
        .map { evaluateExpression($0, context: ctx) }
        .contains { $0.comparable() == .value(.bool(true), path: .empty) }

      return .value(.bool(pass), path: .empty)

    case .not:

      guard
        let expression = expressions.first,
        case .value(.bool(let boolVal), let path) = selectFilter(expression, context: ctx)
      else {
        return .nothing
      }

      return .value(.bool(!boolVal), path: path)
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
      return .value(.bool(evaluateEqual(l, r)), path: .empty)
    case .ne:
      return .value(.bool(evaluateEqual(l, r) == false), path: .empty)
    case .lt:
      return .value(.bool(evaluateLessThan(l, r)), path: .empty)
    case .le:
      return .value(.bool(evaluateLessThan(l, r) || evaluateEqual(l, r)), path: .empty)
    case .gt:
      return .value(.bool(evaluateLessThan(r, l)), path: .empty)
    case .ge:
      return .value(.bool(evaluateLessThan(r, l) || evaluateEqual(l, r)), path: .empty)
    }
  }

  static func evaluateEqual(_ l: Result, _ r: Result) -> Bool {
    switch (l.comparable(), r.comparable()) {
    case (.nothing, .nothing), (.nothing, .empty), (.empty, .nothing):
      return true
    case (.value(let lVal, _), .value(let rVal, _)):
      return lVal == rVal
    case (.nodelist(let lVal), .nodelist(let rVal)):
      return lVal.map(\.value) == rVal.map(\.value)
    default:
      return false
    }
  }

  static func evaluateLessThan(_ l: Result, _ r: Result) -> Bool {
    switch (l.comparable(), r.comparable()) {
    case (.nothing, _), (_, .nothing), (.empty, _), (_, .empty):
      return false
    case (.value(.number(let lVal), _), .value(.number(let rVal), _)):
      return lVal.decimal < rVal.decimal
    case (.value(.string(let lVal), _), .value(.string(let rVal), _)):
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

      case (.value, .value(let value, let path)):
        arguments.append(.value(value, path: path))

      case (.logical, .value(.bool(let value), _)):
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
    case .value(let value, let path):
      .value(value, path: path)
    case .logical(let value):
      .value(.bool(value), path: .empty)
    case .nodes(let nodes):
      .nodelist(nodes)
    }
  }

}

private extension PathQuery.Result {

  func comparable() -> Self {
    switch self {
    case .value(let value, _):
      return .value(value, path: .empty)
    case .nodelist(let list) where list.count == 1:
      return .value(list[0].value, path: .empty)
    case .nodelist(let list):
      return .nodelist(list.map { ($0.value, .empty) })
    default:
      return self
    }
  }

  func argument() -> PathQuery.Function.Argument {
    switch self {
    case .nothing:
      return .nothing
    case .value(let value, let path):
      return .value(value, path: path)
    case .nodelist(let list):
      return .nodes(list)
    }
  }

  var children: [(Value, Path)] {
    switch self {
    case .value(.object(let object), let path):
      return object.map { (key, value) in (value, path.appending(name: key.stringified)) }
    case .value(.array(let array), let path):
      return array.enumerated().map { (index, value) in (value, path.appending(index: index)) }
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
    case (.nothing, .value(let value, let path)), (.value(let value, let path), .nothing):
      return .value(value, path: path)
    case (.nothing, .nodelist(let list)), (.nodelist(let list), .nothing):
      return .nodelist(list)
    case (.value(let l, let lp), .value(let r, let rp)):
      return .nodelist([(l, lp), (r, rp)])
    case (.value(let l, let lp), .nodelist(let r)):
      return .nodelist([(l, lp)] + r)
    case (.nodelist(let l), .value(let r, let rp)):
      return .nodelist(l + [(r, rp)])
    case (.nodelist(let l), .nodelist(let r)):
      return .nodelist(l + r)
    }
  }
}
