//
//  Path-Query-Evaluate.swift
//  Codex
//
//  Created by Kevin Wooten on 1/30/25.
//

internal extension Path.Query {

  typealias Result = Path.Function.Argument

  struct Context {

    var root: Value
    var current: NodeList
    var delegate: Delegate? = nil
    var functions: [String: Path.Function] = [:]

    func rootContext() -> Self {
      var copy = self
      copy.current = [(root, .root)]
      return copy
    }

    func withCurrent(_ node: Node) -> Self {
      var copy = self
      copy.current = .init([node])
      return copy
    }

    func withCurrent(_ nodes: NodeList) -> Self {
      var copy = self
      copy.current = nodes
      return copy
    }

    func withFunctions(_ functions: [Path.Function]) -> Self {
      var copy = self
      copy.functions = functions.reduce(into: [:]) { result, function in
        result[function.name] = function
      }
      return copy
    }

  }

  static func evaluate(segments: [Path.Segment], context ctx: Context) -> NodeList {

    var currentNodes = ctx.current

    for segment in segments {

      switch segment {

      case .child(let selectors, _):
        currentNodes = selectChildren(of: selectors, context: ctx.withCurrent(currentNodes))

      case .descendant(let selectors, _):
        currentNodes = selectDescendants(of: selectors, context: ctx.withCurrent(currentNodes))
      }
    }

    return currentNodes
  }

  static func selectChildren(of selectors: [Path.Selector], context ctx: Context) -> NodeList {

    var selectedNodes: NodeList = .empty

    for selector in selectors {
      let selectorNodes = select(selector: selector, context: ctx.withCurrent(ctx.current))
      selectedNodes += selectorNodes
    }

    return selectedNodes
  }

  static func selectDescendants(of selectors: [Path.Selector], context ctx: Context) -> NodeList {

    var selectedNodes: NodeList = []

    let children = selectChildren(of: selectors, context: ctx)
    selectedNodes += children

    for node in ctx.current.children {
      let descendants = selectDescendants(of: selectors, context: ctx.withCurrent(node))
      selectedNodes += descendants
    }

    return selectedNodes
  }

  static func select(selector: Path.Selector, context ctx: Context) -> NodeList {

    switch selector {

    case .name(let name, _):
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

  static func selectName(_ name: String, context ctx: Context) -> NodeList {

    return ctx.current.flatMap { node -> NodeList in

      guard
        case .object(let object) = node.value,
        let value = object[.string(name)]
      else {
        return []
      }

      return [(value, node.path.appending(name: name))]
    }
  }

  static func selectWildcard(context ctx: Context) -> NodeList {

    return ctx.current.flatMap { node -> NodeList in

      switch node.value {
      case .object(let object):
        return NodeList(object.map { .node($0.value, node.path.appending(name: $0.key.stringified)) })
      case .array(let array):
        return NodeList(array.enumerated().map { (index, value) in .node(value, node.path.appending(index: index)) })
      default:
        return []
      }
    }
  }

  static func selectIndex(_ index: Int, context ctx: Context) -> NodeList {

    return selectSlice(.init(start: index, end: index + 1, step: 1), context: ctx)
  }

  static func selectSlice(_ slice: Path.Selector.Slice, context ctx: Context) -> NodeList {

    return ctx.current.flatMap { node -> NodeList in

      guard case .array(let array) = node.value else {
        return []
      }

      let step = slice.step ?? 1
      let start = slice.start ?? (step >= 0 ? 0 : array.count - 1)
      let end = slice.end ?? (step >= 0 ? array.count : -array.count - 1)
      let (lower, upper) = bounds(start, end, step, array.count)

      var selected: NodeList = []

      if step > 0 {
        var i = lower
        while i < upper {
          selected.append(.node(array[i], node.path.appending(index: i)))
          i += step
        }
      } else {
        var i = upper
        while lower < i {
          selected.append(.node(array[i], node.path.appending(index: i)))
          i += step
        }
      }

      return selected
    }

    func bounds(_ start: Int, _ end: Int, _ step: Int, _ len: Int) -> (Int, Int) {
      let nStart = normalize(start, len)
      let nEnd = normalize(end, len)

      guard step >= 0 else {
        let upper = min(max(nStart, -1), len - 1)
        let lower = min(max(nEnd, -1), len - 1)
        return (lower, upper)
      }
      let lower = min(max(nStart, 0), len)
      let upper = min(max(nEnd, 0), len)
      return (lower, upper)
    }

    func normalize(_ i: Int, _ len: Int) -> Int {
      guard i >= 0 else {
        return len + i
      }
      return i
    }
  }

  static func selectFilter(_ filter: Path.Selector.Expression, context ctx: Context) -> NodeList {

    return ctx.current.children.compactMap { node in

      let result = evaluateLogical(filter, context: ctx.withCurrent(node))
      guard result else {
        return nil
      }
      return node
    }
  }

  static func evaluateLogical(_ expression: Path.Selector.Expression, context ctx: Context) -> Bool {
    return switch expression {
    case .logical(operator: let op, expressions: let expressions):
      evaluateLogical(op, expressions: expressions, context: ctx)

    case .comparison(left: let left, operator: let op, right: let right):
      evaluateComparison(op, left: left, right: right, context: ctx)

    case .test(expression: let expression, negated: let negated):
      evaluateTest(expression, negated: negated, context: ctx)

    case .parenthesis(let expr):
      evaluateLogical(expr, context: ctx)

    default:
      fatalError("Unexpected logical expression: \(expression)")
    }
  }

  static func evaluateTest(_ test: Path.Selector.Expression, negated: Bool, context ctx: Context) -> Bool {

    switch test {

    // Test if any nodes were selected from a query
    case .query(let nodeId, let segments), .singularQuery(let nodeId, let segments):
      let nodes = evaluate(segments: segments, context: nodeId.context(from: ctx))
      return nodes.isEmpty == (negated ? true : false)

    // Test result of a function
    case .function(let name, arguments: let arguments):

      switch evaluateFunction(name, argumentExpressions: arguments, context: ctx) {

      case .logical(let logical):
        return negated ? !logical : logical

      case .nodes(let list):
        return negated ? list.isEmpty : !list.isEmpty

      default:
        return false
      }

    default:
      return false
    }
  }

  static func evaluateLogical(
    _ op: Path.Selector.Expression.LogicalOperator,
    expressions: [Path.Selector.Expression],
    context ctx: Context
  ) -> Bool {

    switch op {

    case .and:

      let pass = expressions.lazy
        .map { evaluateLogical($0, context: ctx) }
        .allSatisfy(\.self)

      return pass

    case .or:

      let pass = expressions.lazy
        .map { evaluateLogical($0, context: ctx) }
        .anySatisfy(\.self)

      return pass

    case .not:

      guard
        expressions.count == 1,
        let expression = expressions.first
      else {
        return false
      }

      let pass = selectFilter(expression, context: ctx).isEmpty == false

      return !pass
    }
  }

  static func evaluateComparison(
    _ op: Path.Selector.Expression.ComparisonOperator,
    left: Path.Selector.Expression,
    right: Path.Selector.Expression,
    context ctx: Context
  ) -> Bool {

    let l = evaluateComparable(left, context: ctx)
    let r = evaluateComparable(right, context: ctx)

    switch op {
    case .eq:
      return evaluateEqual(l, r)
    case .ne:
      return evaluateEqual(l, r) == false
    case .lt:
      return evaluateLessThan(l, r)
    case .le:
      return evaluateLessThan(l, r) || evaluateEqual(l, r)
    case .gt:
      return evaluateLessThan(r, l)
    case .ge:
      return evaluateLessThan(r, l) || evaluateEqual(l, r)
    }
  }

  static func evaluateComparable(_ expression: Path.Selector.Expression, context ctx: Context) -> Result {

    return switch expression {
    case .literal(let value, quote: _):
      .value(value, path: nil)

    case .singularQuery(let nodeId, segments: let segments):
      evaluateSingularQuery(segments: segments, context: nodeId.context(from: ctx))

    case .function(name: let name, arguments: let arguments):
      switch evaluateFunction(name, argumentExpressions: arguments, context: ctx) {

      case .value(let value, let path):
        .value(value, path: path)

      case .logical, .nodes, .nothing:
        .nothing
      }

    default:
      .nothing
    }

    func evaluateSingularQuery(segments: [Path.Segment], context ctx: Context) -> Result {
      let nodes = evaluate(segments: segments, context: ctx)
      if nodes.isEmpty {
        return .nodes([])
      }
      guard nodes.count == 1 else {
        return .nothing
      }
      let node = nodes[0]
      return .value(node.value, path: node.path)
    }
  }

  static func evaluateEqual(_ l: Result, _ r: Result) -> Bool {
    switch (l, r) {
    case (.nothing, .nothing), (.nothing, .empty), (.empty, .nothing):
      return true
    case (.value(let lVal, _), .value(let rVal, _)):
      return lVal == rVal
    case (.nodes(let lVal), .nodes(let rVal)):
      return lVal.map(\.value) == rVal.map(\.value)
    default:
      return false
    }
  }

  static func evaluateLessThan(_ l: Result, _ r: Result) -> Bool {
    switch (l, r) {
    case (.nothing, _), (_, .nothing):
      return false
    case (.value(.number(let lVal), _), .value(.number(let rVal), _)):
      return lVal.decimal < rVal.decimal
    case (.value(.string(let lVal), _), .value(.string(let rVal), _)):
      return lVal < rVal
    default:
      return false
    }
  }

  static func evaluateArgument(_ expression: Path.Selector.Expression, context ctx: Context) -> Result {
    switch expression {
    case .literal(let value, _):
      return .value(value, path: nil)

    case .singularQuery(node: let nodeId, segments: let segments):
      let nodes = evaluate(segments: segments, context: nodeId.context(from: ctx))
      guard !nodes.isEmpty else {
        return .nothing
      }
      let node = nodes[0]
      return .value(node.value, path: node.path)

    case .query(node: let nodeId, segments: let segments):
      return .nodes(Array(evaluate(segments: segments, context: nodeId.context(from: ctx))))

    case .logical(operator: let op, expressions: let exprs):
      return .value(.bool(evaluateLogical(op, expressions: exprs, context: ctx)), path: nil)

    case .function(name: let name, arguments: let arguments):
      return evaluateFunction(name, argumentExpressions: arguments, context: ctx)

    default:
      fatalError("Unexpected argument expression: \(expression)")
    }
  }

  static func evaluateFunction(
    _ name: String,
    argumentExpressions: [Path.Selector.Expression],
    context ctx: Context
  ) -> Path.Query.Result {

    guard let function = ctx.functions[name] else {
      return .nothing
    }

    var arguments: [Path.Function.Argument] = []

    for (argumentIndex, argumentType) in function.arguments.enumerated() {

      let argumentResult = evaluateArgument(argumentExpressions[argumentIndex], context: ctx)
      switch (argumentType, argumentResult) {

      case (.value, .value(let value, let path)):
        arguments.append(.value(value, path: path))

      case (.logical, .value(.bool(let value), _)):
        arguments.append(.logical(value))

      case (.logical, .nodes(let nodes)):
        arguments.append(.logical(!nodes.isEmpty))

      case (.nodes, .nodes(let nodes)):
        arguments.append(.nodes(nodes))

      default:

        ctx.delegate?
          .functionArgumentTypeMismatch(
            function: function,
            argumentIndex: argumentIndex,
            expectedType: argumentType,
            actual: argumentResult
          )

        return .nothing
      }
    }

    do {
      return try function.execute(arguments)
    } catch {
      ctx.delegate?.functionEvaluationFailed(function: function, arguments: arguments, error: error)
      return .nothing
    }
  }

}

private extension Path.Query.NodeList {

  var children: Path.Query.NodeList {
    flatMap { node -> Path.Query.NodeList in
      switch node.value {
      case .object(let object):
        return .init(object.map { (key, value) in .node(value, node.path.appending(name: key.stringified)) })
      case .array(let array):
        return .init(array.enumerated().map { (index, value) in .node(value, node.path.appending(index: index)) })
      default:
        return []
      }
    }
  }

}

private extension Path.Identifier {

  func context(from context: Path.Query.Context) -> Path.Query.Context {
    switch self {
    case .root: context.rootContext()
    case .current where context.current.count == 1: context
    default: context.withCurrent(.empty)
    }
  }

}
