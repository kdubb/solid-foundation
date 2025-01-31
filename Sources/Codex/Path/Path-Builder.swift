//
//  PathParserUtils.swift
//  Codex
//
//  Created by Kevin Wooten on 1/25/25.
//

import Antlr4

extension Path {

  class Builder: PathBaseListener {

    public enum Error: Swift.Error {
      case `internal`(String)
      case recognition(token: String, location: (line: Int, column: Int))
    }

    public static func parse(_ path: String) throws -> Path {

      let builder = Builder()

      let parser = try PathParser(CommonTokenStream(PathLexer(ANTLRInputStream(path))))
      parser.addParseListener(builder)

      try parser.pathQuery()

      if let error = builder.errors.first {
        throw error
      }
      return Path(segments: builder.segmentsStack.popLast() ?? [])
    }

    var segmentsStack: [[Path.Segment]] = []
    var selectorsStack: [[Path.Selector]] = []
    var expressionsStack: [[Path.Selector.Expression]] = []
    var comparisonOperatorStack: [Path.Selector.Expression.ComparisonOperator] = []
    var errors: [Swift.Error] = []

    func valid(_ ctx: ParserRuleContext, _ block: () throws -> Void) {
      for child in ctx.children ?? [] {
        if let childCtx = child as? ParserRuleContext, let exc = childCtx.exception {
          let token = exc.getOffendingToken()
          errors.append(Error.recognition(token: token.getText() ?? "", location: (token.getLine(), token.getCharPositionInLine())))
        }
      }
      guard errors.isEmpty else {
        return
      }
      do {
        try block()
      } catch {
        errors.append(error)
      }
    }

    func addSegments(_ segments: Path.Segment...) {
      let currentSegments = segmentsStack.popLast() ?? []
      segmentsStack.append(currentSegments + segments)
    }

    func addSelectors(_ selectors: [Path.Selector]) {
      let currentSelectors = selectorsStack.popLast() ?? []
      selectorsStack.append(currentSelectors + selectors)
    }

    func addExpressions(_ expressions: [Path.Selector.Expression]) {
      let currentExpressions = expressionsStack.popLast() ?? []
      expressionsStack.append(currentExpressions + expressions)
    }

    override func enterChildSegment(_ ctx: PathParser.ChildSegmentContext) {
      selectorsStack.append([])
    }

    override func exitChildSegment(_ ctx: PathParser.ChildSegmentContext) {
      valid(ctx) {
        guard let selectors = selectorsStack.popLast() else {
          throw Error.internal("child segment")
        }
        addSegments(.child(selectors))
      }
    }

    override func enterDescendantSegment(_ ctx: PathParser.DescendantSegmentContext) {
      selectorsStack.append([])
    }

    override func exitDescendantSegment(_ ctx: PathParser.DescendantSegmentContext) {
      valid(ctx) {
        guard let selectors = selectorsStack.popLast() else {
          throw Error.internal("descendant segment")
        }
        addSegments(.descendant(selectors))
      }
    }

    override func enterBracketedSelection(_ ctx: PathParser.BracketedSelectionContext) {
      selectorsStack.append([])
    }

    override func exitBracketedSelection(_ ctx: PathParser.BracketedSelectionContext) {
      valid(ctx) {
        guard let selectors = selectorsStack.popLast() else {
          throw Error.internal("bracketed selection")
        }
        addSelectors(selectors)
      }
    }

    override func exitMemberNameShorthand(_ ctx: PathParser.MemberNameShorthandContext) {
      valid(ctx) {
        addSelectors([.name(ctx.getText())])
      }
    }

    override func enterNameSegment(_ ctx: PathParser.NameSegmentContext) {
      selectorsStack.append([])
    }

    override func exitNameSegment(_ ctx: PathParser.NameSegmentContext) {
      valid(ctx) {
        guard let selectors = selectorsStack.popLast() else {
          throw Error.internal("name segment")
        }
        addSegments(.child(selectors))
      }
    }

    override func exitNameSelector(_ ctx: PathParser.NameSelectorContext) {
      valid(ctx) {
        guard
          let expressions = expressionsStack.popLast(),
          expressions.count == 1,
          case .literal(let literal) = expressions[0],
          case .string(let string) = literal
        else {
          throw Error.internal("name selector")
        }
        addSelectors([.name(string)])
      }
    }

    override func exitIndexSelector(_ ctx: PathParser.IndexSelectorContext) {
      valid(ctx) {
        guard let index = (ctx.INT()?.getText()).map({ Int($0) }) ?? nil else {
          throw Error.internal("index selector")
        }
        addSelectors([.index(index)])
      }
    }

    override func exitWildcardSelector(_ ctx: PathParser.WildcardSelectorContext) {
      addSelectors([.wildcard])
    }

    override func exitSliceSelector(_ ctx: PathParser.SliceSelectorContext) {
      valid(ctx) {
        let start = (ctx.slice()?.start()?.getText()).map { Int($0) } ?? nil
        let end = (ctx.slice()?.end()?.getText()).map { Int($0) } ?? nil
        let step = (ctx.slice()?.step()?.getText()).map { Int($0) } ?? nil
        addSelectors([.slice(Path.Selector.Slice(start: start, end: end, step: step))])
      }
    }

    override func enterFilterSelector(_ ctx: PathParser.FilterSelectorContext) {
      expressionsStack.append([])
    }

    override func exitFilterSelector(_ ctx: PathParser.FilterSelectorContext) {
      valid(ctx) {
        guard let expressions = expressionsStack.popLast(), expressions.count == 1 else {
          throw Error.internal("filter selector")
        }
        addSelectors([.filter(expressions[0])])
      }
    }

    override func enterLogicalAndExpr(_ ctx: PathParser.LogicalAndExprContext) {
      expressionsStack.append([])
    }

    override func exitLogicalAndExpr(_ ctx: PathParser.LogicalAndExprContext) {
      valid(ctx) {
        guard let expressions = expressionsStack.popLast() else {
          throw Error.internal("logical and expression")
        }
        if expressions.count == 1 {
          addExpressions(expressions)
        } else {
          addExpressions([.logical(operator: .and, expressions: expressions)])
        }
      }
    }

    override func enterLogicalOrExpr(_ ctx: PathParser.LogicalOrExprContext) {
      expressionsStack.append([])
    }

    override func exitLogicalOrExpr(_ ctx: PathParser.LogicalOrExprContext) {
      valid(ctx) {
        guard let expressions = expressionsStack.popLast() else {
          throw Error.internal("logical or expression")
        }
        if expressions.count == 1 {
          addExpressions(expressions)
        } else {
          addExpressions([.logical(operator: .or, expressions: expressions)])
        }
      }
    }

    override func enterParenExpr(_ ctx: PathParser.ParenExprContext) {
      expressionsStack.append([])
    }

    override func exitParenExpr(_ ctx: PathParser.ParenExprContext) {
      valid(ctx) {
        guard let expressions = expressionsStack.popLast() else {
          throw Error.internal("paren expression")
        }
        if ctx.logicalNotOp() != nil {
          addExpressions([.logical(operator: .not, expressions: expressions)])
        } else {
          addExpressions(expressions)
        }
      }
    }

    override func enterTestExpr(_ ctx: PathParser.TestExprContext) {
      expressionsStack.append([])
    }

    override func exitTestExpr(_ ctx: PathParser.TestExprContext) {
      valid(ctx) {
        guard let expressions = expressionsStack.popLast(), expressions.count == 1 else {
          throw Error.internal("test expression")
        }
        let negated = ctx.logicalNotOp() != nil
        addExpressions([.test(expression: expressions[0], negated: negated)])
      }
    }

    override func enterComparisonExpr(_ ctx: PathParser.ComparisonExprContext) {
      expressionsStack.append([])
    }

    override func exitComparisonExpr(_ ctx: PathParser.ComparisonExprContext) {
      valid(ctx) {
        guard
          let expressions = expressionsStack.popLast(),
          let opText = ctx.comparisonOp()?.getText(),
          let op = Path.Selector.Expression.ComparisonOperator(rawValue: opText)
        else {
          throw Error.internal("comparison operator")
        }
        addExpressions([.comparison(left: expressions[0], operator: op, right: expressions[1])])
      }
    }

    override func enterSingularQuery(_ ctx: PathParser.SingularQueryContext) {
      segmentsStack.append([])
    }

    override func exitRelSingularQuery(_ ctx: PathParser.RelSingularQueryContext) {
      valid(ctx) {
        guard let segments = segmentsStack.popLast() else {
          throw Error.internal("singular query")
        }
        addExpressions([.singularQuery(segments: segments, type: .relative)])
      }
    }

    override func exitAbsSingularQuery(_ ctx: PathParser.AbsSingularQueryContext) {
      valid(ctx) {
        guard let segments = segmentsStack.popLast() else {
          throw Error.internal("singular query")
        }
        addExpressions([.singularQuery(segments: segments, type: .absolute)])
      }
    }

    override func enterPathQuery(_ ctx: PathParser.PathQueryContext) {
      segmentsStack.append([])
    }

    override func exitPathQuery(_ ctx: PathParser.PathQueryContext) {
      valid(ctx) {
        if !expressionsStack.isEmpty {
          guard let segments = segmentsStack.popLast() else {
            throw Error.internal("path query")
          }
          addExpressions([.query(segments: segments, type: .absolute)])
        }
      }
    }

    override func enterRelQuery(_ ctx: PathParser.RelQueryContext) {
      segmentsStack.append([])
    }

    override func exitRelQuery(_ ctx: PathParser.RelQueryContext) {
      valid(ctx) {
        guard let segments = segmentsStack.popLast() else {
          throw Error.internal("relative query")
        }
        addExpressions([.query(segments: segments, type: .relative)])
      }
    }

    override func enterFunctionExpr(_ ctx: PathParser.FunctionExprContext) {
      expressionsStack.append([])
    }

    override func exitFunctionExpr(_ ctx: PathParser.FunctionExprContext) {
      valid(ctx) {
        guard let name = ctx.functionName()?.getText(), let expressions = expressionsStack.popLast() else {
          throw Error.internal("function name")
        }
        addExpressions([.function(name: name, arguments: expressions)])
      }
    }

    override func exitNullLiteral(_ ctx: PathParser.NullLiteralContext) {
      valid(ctx) {
        addExpressions([.literal(.null)])
      }
    }

    override func exitBoolLiteral(_ ctx: PathParser.BoolLiteralContext) {
      valid(ctx) {
        if ctx.TRUE() != nil {
          addExpressions([.literal(.bool(true))])
        } else {
          addExpressions([.literal(.bool(false))])
        }
      }
    }

    override func exitIntLiteral(_ ctx: PathParser.IntLiteralContext) {
      valid(ctx) {
        addExpressions([.literal(.number(Value.TextNumber(text: ctx.getText())))])
      }
    }

    override func exitNumLiteral(_ ctx: PathParser.NumLiteralContext) {
      valid(ctx) {
        addExpressions([.literal(.number(Value.TextNumber(text: ctx.getText())))])
      }
    }

    override func exitStringLiteral(_ ctx: PathParser.StringLiteralContext) {
      valid(ctx) {
        if let str = ctx.DQ_STRING() {
          addExpressions([.literal(.string(String(str.getText().dropFirst().dropLast())))])
        } else if let str = ctx.SQ_STRING() {
          addExpressions([.literal(.string(String(str.getText().dropFirst().dropLast())))])
        }
      }
    }

  }
}
