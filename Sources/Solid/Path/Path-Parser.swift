//
//  Path-Parser.swift
//  SolidFoundation
//
//  Created by Kevin Wooten on 4/6/25.
//

import Foundation

extension Path {

  /// Options for parsing path strings.
  public enum ParseOption {

    /// Capture explicit parentheses in the parsed expression.
    ///
    /// When enabled, parentheses in the path string are captured as part of the parsed expression.
    ///
    /// > Tip: This option is useful when you want to preserve the structure of the original path string. It can
    /// be helpful for debugging or when you need to reconstruct the original path string later.
    ///
    case captureParentheses
  }

  /// Parse an encoded path string into a ``Path`` object.
  ///
  /// - Parameters:
  ///   - string: The path string to parse.
  ///   - options: A set of parsing options to customize the parsing behavior.
  /// - Returns: A ``Path`` object representing the parsed path.
  /// - Throws: A ``ParserError`` if the path string is invalid.
  ///
  public static func parse(string: String, options: Set<ParseOption> = []) throws -> Path {
    let parser = try Parser(string, options: options)
    return try parser.parse()
  }

  class Parser {

    private let tokenStream: TokenRecordingStream<Tokenizer.Token, ParserError>
    private var currentToken: Tokenizer.Token
    private var nextToken: Tokenizer.Token
    private var currentLocation: Tokenizer.Token.Location = .init(line: 1, column: 1)
    private let options: Set<ParseOption>

    init(_ input: String, options: Set<ParseOption>) throws(ParserError) {
      let tokenizer = Tokenizer(input)
      self.tokenStream = TokenRecordingStream(tokenizer)
      self.currentToken = try tokenStream.nextToken()
      self.nextToken = try tokenStream.nextToken()
      self.options = options
    }

    func parse() throws -> Path {
      let segments = try parsePathQuery()
      return Path(segments: segments)
    }

    // pathQuery : ROOT segments EOF;
    private func parsePathQuery() throws(ParserError) -> [Path.Segment] {
      try expect(.root)
      let segments = try parseSegments()
      try expect(.eof)
      return segments
    }

    // segments : segment*;
    private func parseSegments() throws(ParserError) -> [Path.Segment] {
      var segments: [Path.Segment] = []
      while currentToken.isOneOf(.openBracket, .memberAccess, .descendantAccess) {
        segments.append(try parseSegment())
      }
      return segments
    }

    // segment : childSegment | descendantSegment;
    private func parseSegment() throws(ParserError) -> Segment {
      switch currentToken.kind {
      case .openBracket, .memberAccess:
        return try parseChildSegment()
      case .descendantAccess:
        return try parseDescendantSegment()
      default:
        throw .unexpectedToken(currentToken)
      }
    }

    // childSegment : bracketedSelection | MEMBER_ACC (wildcardSelector | memberNameShorthand);
    private func parseChildSegment() throws(ParserError) -> Segment {
      switch currentToken.kind {

      // bracketedSelection
      case .openBracket:
        return .child(try parseBracketedSelection(), shorthand: false)

      // MEMBER_ACC (wildcardSelector | memberNameShorthand);
      case .memberAccess:
        try advance()

        // (wildcardSelector | memberNameShorthand)
        switch currentToken.kind {

        // wildcardSelector
        case .wildcard:
          return .child([try parseWildcardSelector()], shorthand: true)

        // memberNameShorthand
        case .name, .true, .false, .null:
          return try .child([parseMemberNameShorthand()], shorthand: true)

        default:
          throw ParserError.unexpectedToken(currentToken)
        }

      default:
        throw ParserError.unexpectedToken(currentToken)
      }
    }

    // descendantSegment : DESC_ACC (bracketedSelection | wildcardSelector | memberNameShorthand);
    private func parseDescendantSegment() throws(ParserError) -> Segment {
      // DESC_ACC
      try expect(.descendantAccess)

      // (bracketedSelection | wildcardSelector | memberNameShorthand)
      switch currentToken.kind {

      // bracketedSelection
      case .openBracket:
        return try .descendant(parseBracketedSelection(), shorthand: false)

      // wildcardSelector
      case .wildcard:
        return try .descendant([parseWildcardSelector()], shorthand: true)

      // memberNameShorthand
      case .name, .true, .false, .null:
        return try .descendant([parseMemberNameShorthand()], shorthand: true)

      default:
        throw .unexpectedToken(currentToken)
      }
    }

    // selector : nameSelector | wildcardSelector | indexSelector | sliceSelector | filterSelector;
    private func parseSelector() throws(ParserError) -> Path.Selector {
      switch currentToken.kind {

      // nameSelector
      case .string:
        return try parseNameSelector()

      // wildcardSelector
      case .wildcard:
        return try parseWildcardSelector()

      // indexSelector
      case .number where nextToken.kind != .colon:
        return try parseIndexSelector()

      // sliceSelector
      case .colon,
        .number where nextToken.kind == .colon:
        return try parseSliceSelector()

      // filterSelector
      case .filter:
        return try parseFilterSelector()

      default:
        throw .unexpectedToken(currentToken)
      }
    }

    // nameSelector : stringLiteral;
    private func parseNameSelector() throws(ParserError) -> Selector {
      guard case .literal(.string(let string), let quote) = try parseStringLiteral() else {
        throw .unexpectedToken(currentToken)
      }
      return .name(string, quote: quote)
    }

    // wildcardSelector : WILDCARD;
    private func parseWildcardSelector() throws(ParserError) -> Selector {
      try expect(.wildcard)
      return .wildcard
    }

    // indexSelector : intLiteral ;
    private func parseIndexSelector() throws(ParserError) -> Path.Selector {
      guard
        case .literal(.number(let int), _) = try parseIntLiteral(),
        let int: Int = int.int()
      else {
        throw .unexpectedToken(currentToken)
      }
      return .index(int)
    }

    // sliceSelector : slice;
    private func parseSliceSelector() throws(ParserError) -> Path.Selector {
      return .slice(try parseSlice())
    }

    // filterSelector : FILTER s logicalExpr;
    private func parseFilterSelector() throws(ParserError) -> Path.Selector {
      try expect(.filter)
      return .filter(try parseLogicalExpr())
    }

    // memberNameShorthand : name;
    private func parseMemberNameShorthand() throws(ParserError) -> Selector {
      let name = try parseName()
      return .name(name, quote: nil)
    }

    // name : NAME | TRUE | FALSE | NULL;
    private func parseName() throws(ParserError) -> String {
      switch currentToken {
      case .name(let name, _):
        try advance()
        return name
      case .true:
        try advance()
        return "true"
      case .false:
        try advance()
        return "false"
      case .null:
        try advance()
        return "null"
      default:
        throw .unexpectedToken(currentToken)
      }
    }

    // slice : (start s)? COLON s (end s)? (COLON (s step))?;
    private func parseSlice() throws(ParserError) -> Path.Selector.Slice {
      var start: Int?
      var end: Int?
      var step: Int?

      if currentToken.kind == .number {
        guard case .literal(.number(let value), _) = try parseIntLiteral(), let int: Int = value.int() else {
          throw .unexpectedToken(currentToken)
        }
        start = int
      }

      try expect(.colon)

      if currentToken.kind == .number {
        guard case .literal(.number(let value), _) = try parseIntLiteral(), let int: Int = value.int() else {
          throw .unexpectedToken(currentToken)
        }
        end = int
      }

      if currentToken.kind == .colon {
        try advance()
        if currentToken.kind == .number {
          guard case .literal(.number(let value), _) = try parseIntLiteral(), let int: Int = value.int() else {
            throw .unexpectedToken(currentToken)
          }
          step = int
        }
      }

      return Path.Selector.Slice(start: start, end: end, step: step)
    }

    // bracketedSelection : OPEN_BRACKET s selector (s COMMA s selector)* s CLOSE_BRACKET;
    private func parseBracketedSelection() throws(ParserError) -> [Selector] {
      try expect(.openBracket)

      var selectors: [Selector] = []

      // selector
      selectors.append(try parseSelector())

      // (s COMMA s selector)*
      while currentToken.kind != .closeBracket {
        try expect(.comma)
        selectors.append(try parseSelector())
      }

      try expect(.closeBracket)

      return selectors
    }

    // logicalExpr : logicalOrExpr;
    private func parseLogicalExpr() throws(ParserError) -> Path.Selector.Expression {
      return try parseLogicalOrExpr()
    }

    // logicalOrExpr : logicalAndExpr (s LOGICAL_OR s logicalAndExpr)*;
    private func parseLogicalOrExpr() throws(ParserError) -> Path.Selector.Expression {
      var expressions: [Path.Selector.Expression] = [try parseLogicalAndExpr()]
      while currentToken.kind == .logicalOr {
        try advance()
        expressions.append(try parseLogicalAndExpr())
      }
      return expressions.count == 1 ? expressions[0] : .logical(operator: .or, expressions: expressions)
    }

    // logicalAndExpr : basicExpr (s LOGICAL_AND s basicExpr)*;
    private func parseLogicalAndExpr() throws(ParserError) -> Path.Selector.Expression {
      var expressions: [Path.Selector.Expression] = [try parseBasicExpr()]
      while currentToken.kind == .logicalAnd {
        try advance()
        expressions.append(try parseBasicExpr())
      }
      return expressions.count == 1 ? expressions[0] : .logical(operator: .and, expressions: expressions)
    }

    // basicExpr : parenExpr | comparisonExpr | testExpr;
    private func parseBasicExpr() throws(ParserError) -> Path.Selector.Expression {
      switch currentToken.kind {

      // parenExpr
      case .openParen,
        .exclamation where nextToken.kind == .openParen:
        return try parseParenExpr()

      // Disambuguates: comparisonExpr | testExpr
      default:
        // Attempt to parse a singular query
        guard let comparisonExpr = try attempt(parseComparisonExpr) else {
          return try parseTestExpr()
        }
        return comparisonExpr
      }
    }

    // parenExpr : OPEN_PAREN s logicalExpr s CLOSE_PAREN;
    private func parseParenExpr() throws(ParserError) -> Path.Selector.Expression {
      let negated: Bool
      if currentToken.kind == .exclamation {
        try parseLogicalNotOp()
        negated = true
      } else {
        negated = false
      }

      try expect(.openParen)
      let expr = try parseLogicalExpr()
      try expect(.closeParen)

      let negExpr: Path.Selector.Expression =
        if negated {
          .logical(operator: .not, expressions: [expr])
        } else {
          expr
        }

      return options.contains(.captureParentheses) ? .parenthesis(negExpr) : negExpr
    }

    // logicalNotOp : EXCLAMATION_MARK;
    private func parseLogicalNotOp() throws(ParserError) {
      try expect(.exclamation)
    }

    // testExpr : (logicalNotOp s)? (filterQuery | functionExpr);
    private func parseTestExpr() throws(ParserError) -> Path.Selector.Expression {
      let negated: Bool
      if currentToken.kind == .exclamation {
        try parseLogicalNotOp()
        negated = true
      } else {
        negated = false
      }

      let expr =
        switch currentToken.kind {
        case .current, .root:
          try parseFilterQuery()
        case .name:
          try parseFunctionExpr()
        default:
          throw .unexpectedToken(currentToken)
        }

      return .test(expression: expr, negated: negated)
    }

    // filterQuery : relQuery | pathQuery ;
    private func parseFilterQuery() throws(ParserError) -> Path.Selector.Expression {
      switch currentToken.kind {
      case .current:
        return try parseRelQuery()
      case .root:
        return try .query(node: .root, segments: parsePathQuery())
      default:
        throw .unexpectedToken(currentToken)
      }
    }

    // relQuery : CURRENT segments;
    private func parseRelQuery() throws(ParserError) -> Path.Selector.Expression {
      try expect(.current)
      return try .query(node: .current, segments: parseSegments())
    }

    // comparisonExpr : comparable (s comparisonOp s comparable);
    private func parseComparisonExpr() throws(ParserError) -> Path.Selector.Expression {
      let left = try parseComparable()
      let op = try parseComparisonOp()
      let right = try parseComparable()
      return .comparison(left: left, operator: op, right: right)
    }

    // literal : nullLiteral | booleanLiteral | intLiteral | numLiteral | stringLiteral;
    private func parseLiteral() throws(ParserError) -> Path.Selector.Expression {
      switch currentToken {
      case .null:
        return try parseNullLiteral()
      case .true, .false:
        return try parseBoolLiteral()
      case .number:
        return try parseNumLiteral()
      case .string:
        return try parseStringLiteral()
      default:
        throw .unexpectedToken(currentToken)
      }
    }

    // nullLiteral : NULL;
    private func parseNullLiteral() throws(ParserError) -> Path.Selector.Expression {
      try expect(.null)
      return .literal(.null)
    }

    // booleanLiteral : TRUE | FALSE;
    private func parseBoolLiteral() throws(ParserError) -> Path.Selector.Expression {
      switch currentToken {
      case .true:
        try advance()
        return .literal(.bool(true))
      case .false:
        try advance()
        return .literal(.bool(false))
      default:
        throw .unexpectedToken(currentToken)
      }
    }

    // intLiteral : INT;
    private func parseIntLiteral() throws(ParserError) -> Path.Selector.Expression {
      guard
        case .number(let value, _) = currentToken,
        let int = Int(exactly: value)
      else {
        throw .unexpectedToken(currentToken)
      }
      try advance()
      return .literal(.number(int))
    }

    // numberLiteral : INT | NUM;
    private func parseNumLiteral() throws(ParserError) -> Path.Selector.Expression {
      guard case .number(let value, _) = currentToken else {
        throw .unexpectedToken(currentToken)
      }
      try advance()
      return .literal(.number(value))
    }

    // stringLiteral : STRING;
    private func parseStringLiteral() throws(ParserError) -> Path.Selector.Expression {
      guard case .string(let string, let quote, _) = currentToken else {
        throw .unexpectedToken(currentToken)
      }
      try advance()
      return .literal(.string(string), quote: quote)
    }

    // comparable : literal | singularQuery | functionExpr;
    private func parseComparable() throws(ParserError) -> Path.Selector.Expression {
      switch currentToken.kind {
      case .null, .true, .false, .number, .string:
        return try parseLiteral()
      case .current, .root:
        return try parseSingularQuery()
      case .name:
        return try parseFunctionExpr()
      default:
        throw .unexpectedToken(currentToken)
      }
    }

    // comparisonOp : CMP_EQ | CMP_NE | CMP_LT | CMP_LE | CMP_GT | CMP_GE;
    private func parseComparisonOp() throws(ParserError) -> Path.Selector.Expression.ComparisonOperator {
      guard case .comparisonOp(let op, _) = currentToken else {
        throw .unexpectedToken(currentToken)
      }
      try advance()
      return op
    }

    // singularQuery : relSingularQuery | absSingularQuery;
    private func parseSingularQuery() throws(ParserError) -> Path.Selector.Expression {
      switch currentToken.kind {
      case .current:
        return try parseRelSingularQuery()
      case .root:
        return try parseAbsSingularQuery()
      default:
        throw .unexpectedToken(currentToken)
      }
    }

    // relSingularQuery : CURRENT segments;
    private func parseRelSingularQuery() throws(ParserError) -> Path.Selector.Expression {
      try expect(.current)
      let segments = try parseSingularQuerySegments()
      return .singularQuery(node: .current, segments: segments)
    }

    // absSingularQuery : ROOT segments;
    private func parseAbsSingularQuery() throws(ParserError) -> Path.Selector.Expression {
      try expect(.root)
      let segments = try parseSingularQuerySegments()
      return .singularQuery(node: .root, segments: segments)
    }

    // singularQuerySegments : (s (nameSegment | indexSegment))*
    private func parseSingularQuerySegments() throws(ParserError) -> [Path.Segment] {
      var segments: [Path.Segment] = []
      while currentToken.isOneOf(.memberAccess, .openBracket) {
        switch currentToken.kind {
        case .memberAccess:
          segments.append(try parseNameSegment())
        case .openBracket:
          do {
            segments.append(try parseIndexSegment())
          } catch {
            segments.append(try parseNameSegment())
          }
        default:
          throw .unexpectedToken(currentToken)
        }
      }
      return segments
    }

    // nameSegment : (OPEN_BRACKET nameSelector CLOSE_BRACKET) | (MEMBER_ACC memberNameShorthand);
    private func parseNameSegment() throws(ParserError) -> Path.Segment {
      switch currentToken.kind {

      // OPEN_BRACKET nameSelector CLOSE_BRACKET
      case .openBracket:
        try advance()
        let selector = try parseNameSelector()
        try expect(.closeBracket)
        return .child([selector])

      // MEMBER_ACC memberNameShorthand
      case .memberAccess:
        try advance()
        return .child([try parseMemberNameShorthand()], shorthand: true)

      default:
        throw .unexpectedToken(currentToken)
      }
    }

    // indexSegment : OPEN_BRACKET indexSelector CLOSE_BRACKET;
    private func parseIndexSegment() throws(ParserError) -> Path.Segment {
      try expect(.openBracket)
      let selector = try parseIndexSelector()
      try expect(.closeBracket)
      return .child([selector])
    }

    // functionName : FUNC_NAME;
    private func parseFunctionName() throws(ParserError) -> String {
      guard case .name(let name, _) = currentToken else {
        throw .unexpectedToken(currentToken)
      }
      try advance()
      return name
    }

    // functionExpr : FUNC_NAME OPEN_PAREN s (functionArgument (s COMMA s functionArgument)*)? s CLOSE_PAREN;
    private func parseFunctionExpr() throws(ParserError) -> Path.Selector.Expression {
      let name = try parseFunctionName()
      var args: [Path.Selector.Expression] = []
      try expect(.openParen)
      switch currentToken.kind {
      case .closeParen:
        break
      default:
        args.append(try parseFunctionArgument())
        while currentToken.kind != .closeParen {
          try expect(.comma)
          args.append(try parseFunctionArgument())
        }
      }
      try expect(.closeParen)
      return .function(name: name, arguments: args)
    }

    // functionArgument : literal | functionExpr | filterQuery | logicalExpr;
    private func parseFunctionArgument() throws(ParserError) -> Path.Selector.Expression {
      switch currentToken.kind {
      case .null, .true, .false, .number, .string:
        return try parseLiteral()
      case .name:
        return try parseFunctionExpr()
      case .current, .root:
        let expr = try parseFilterQuery()
        return if case .query(let nodeId, let segments) = expr, segments.allSatisfy(\.isSingularQuerySegment) {
          .singularQuery(node: nodeId, segments: segments)
        } else {
          expr
        }
      default:
        return try parseLogicalExpr()
      }
    }

    private func attempt<R>(_ rule: () throws(ParserError) -> R) throws(ParserError) -> R? {
      tokenStream.record(initialTokens: [currentToken, nextToken])
      do {
        let result = try rule()
        tokenStream.stop()
        return result
      } catch .unexpectedToken {
        tokenStream.replay()
        currentToken = try tokenStream.nextToken()
        nextToken = try tokenStream.nextToken()
        return nil
      }
    }

    private func advance() throws(ParserError) {
      currentToken = nextToken
      nextToken = try tokenStream.nextToken()
    }

    private func expect(_ expected: Tokenizer.Token.Kind) throws(ParserError) {
      guard currentToken.kind == expected else {
        throw ParserError.unexpectedToken(currentToken)
      }
      try advance()
    }

  }
}

private extension Path.Segment {

  var isSingularQuerySegment: Bool {
    guard case .child(let selectors, _) = self else {
      return false
    }
    return selectors.allSatisfy { selector in
      switch selector {
      case .name, .index: true
      default: false
      }
    }

  }

}
