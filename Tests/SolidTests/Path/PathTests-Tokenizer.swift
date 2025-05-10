import Testing
@testable import Solid

extension PathTests {

  @Suite("Tokenizing")
  final class PathTokenizerTests {

    @Test("Root Token")
    func testRootToken() throws {
      let tokenizer = Path.Tokenizer("$")
      let token = try tokenizer.nextToken()
      #expect(token.kind == .root)
      #expect(token.location.line == 1)
      #expect(token.location.column == 1)
    }

    @Test("Current Token")
    func testCurrentToken() throws {
      let tokenizer = Path.Tokenizer("@")
      let token = try tokenizer.nextToken()
      #expect(token.kind == .current)
      #expect(token.location.line == 1)
      #expect(token.location.column == 1)
    }

    @Test("Member Access Token")
    func testMemberAccessToken() throws {
      let tokenizer = Path.Tokenizer(".")
      let token = try tokenizer.nextToken()
      #expect(token.kind == .memberAccess)
      #expect(token.location.line == 1)
      #expect(token.location.column == 1)
    }

    @Test("Descendant Access Token")
    func testDescendantAccessToken() throws {
      let tokenizer = Path.Tokenizer("..")
      let token = try tokenizer.nextToken()
      #expect(token.kind == .descendantAccess)
      #expect(token.location.line == 1)
      #expect(token.location.column == 1)
    }

    @Test("Wildcard Token")
    func testWildcardToken() throws {
      let tokenizer = Path.Tokenizer("*")
      let token = try tokenizer.nextToken()
      #expect(token.kind == .wildcard)
      #expect(token.location.line == 1)
      #expect(token.location.column == 1)
    }

    @Test("Filter Token")
    func testFilterToken() throws {
      let tokenizer = Path.Tokenizer("?")
      let token = try tokenizer.nextToken()
      #expect(token.kind == .filter)
      #expect(token.location.line == 1)
      #expect(token.location.column == 1)
    }

    @Test("Colon Token")
    func testColonToken() throws {
      let tokenizer = Path.Tokenizer(":")
      let token = try tokenizer.nextToken()
      #expect(token.kind == .colon)
      #expect(token.location.line == 1)
      #expect(token.location.column == 1)
    }

    @Test("Semicolon Token")
    func testSemicolonToken() throws {
      let tokenizer = Path.Tokenizer(";")
      let token = try tokenizer.nextToken()
      #expect(token.kind == .semicolon)
      #expect(token.location.line == 1)
      #expect(token.location.column == 1)
    }

    @Test("Open Bracket Token")
    func testOpenBracketToken() throws {
      let tokenizer = Path.Tokenizer("[")
      let token = try tokenizer.nextToken()
      #expect(token.kind == .openBracket)
      #expect(token.location.line == 1)
      #expect(token.location.column == 1)
    }

    @Test("Close Bracket Token")
    func testCloseBracketToken() throws {
      let tokenizer = Path.Tokenizer("]")
      let token = try tokenizer.nextToken()
      #expect(token.kind == .closeBracket)
      #expect(token.location.line == 1)
      #expect(token.location.column == 1)
    }

    @Test("Open Paren Token")
    func testOpenParenToken() throws {
      let tokenizer = Path.Tokenizer("(")
      let token = try tokenizer.nextToken()
      #expect(token.kind == .openParen)
      #expect(token.location.line == 1)
      #expect(token.location.column == 1)
    }

    @Test("Close Paren Token")
    func testCloseParenToken() throws {
      let tokenizer = Path.Tokenizer(")")
      let token = try tokenizer.nextToken()
      #expect(token.kind == .closeParen)
      #expect(token.location.line == 1)
      #expect(token.location.column == 1)
    }

    @Test("Comma Token")
    func testCommaToken() throws {
      let tokenizer = Path.Tokenizer(",")
      let token = try tokenizer.nextToken()
      #expect(token.kind == .comma)
      #expect(token.location.line == 1)
      #expect(token.location.column == 1)
    }

    @Test("Exclamation Token")
    func testExclamationToken() throws {
      let tokenizer = Path.Tokenizer("!")
      let token = try tokenizer.nextToken()
      #expect(token.kind == .exclamation)
      #expect(token.location.line == 1)
      #expect(token.location.column == 1)
    }

    @Test("Logical And Token")
    func testLogicalAndToken() throws {
      let tokenizer = Path.Tokenizer("&&")
      let token = try tokenizer.nextToken()
      #expect(token.kind == .logicalAnd)
      #expect(token.location.line == 1)
      #expect(token.location.column == 1)
    }

    @Test("Logical Or Token")
    func testLogicalOrToken() throws {
      let tokenizer = Path.Tokenizer("||")
      let token = try tokenizer.nextToken()
      #expect(token.kind == .logicalOr)
      #expect(token.location.line == 1)
      #expect(token.location.column == 1)
    }

    @Test("Comparison Operators")
    func testComparisonOpTokens() throws {
      let operators = [
        ("==", Path.Selector.Expression.ComparisonOperator.eq),
        ("!=", Path.Selector.Expression.ComparisonOperator.ne),
        (">", Path.Selector.Expression.ComparisonOperator.gt),
        (">=", Path.Selector.Expression.ComparisonOperator.ge),
        ("<", Path.Selector.Expression.ComparisonOperator.lt),
        ("<=", Path.Selector.Expression.ComparisonOperator.le),
      ]

      for (input, expectedOp) in operators {
        let tokenizer = Path.Tokenizer(input)
        let token = try tokenizer.nextToken()
        guard case .comparisonOp(let op, _) = token else {
          Issue.record("Expected comparison operator token")
          return
        }
        #expect(op == expectedOp)
        #expect(token.location.line == 1)
        #expect(token.location.column == 1)
      }
    }

    @Test("Name Token")
    func testNameToken() throws {
      let tokenizer = Path.Tokenizer("name")
      let token = try tokenizer.nextToken()
      guard case .name(let name, _) = token else {
        Issue.record("Expected name token")
        return
      }
      #expect(name == "name")
      #expect(token.location.line == 1)
      #expect(token.location.column == 1)
    }

    @Test("Number Token")
    func testNumberToken() throws {
      let tokenizer = Path.Tokenizer("123")
      let token = try tokenizer.nextToken()
      guard case .number(let value, _) = token else {
        Issue.record("Expected number token")
        return
      }
      #expect(value == BigDecimal("123"))
      #expect(token.location.line == 1)
      #expect(token.location.column == 1)
    }

    @Test("String Token")
    func testStringToken() throws {
      let tokenizer = Path.Tokenizer("\"hello\"")
      let token = try tokenizer.nextToken()
      guard case .string(let value, let quote, _) = token else {
        Issue.record("Expected string token")
        return
      }
      #expect(value == "hello")
      #expect(quote == "\"")
      #expect(token.location.line == 1)
      #expect(token.location.column == 1)
    }

    @Test("True Token")
    func testTrueToken() throws {
      let tokenizer = Path.Tokenizer("true")
      let token = try tokenizer.nextToken()
      #expect(token.kind == .true)
      #expect(token.location.line == 1)
      #expect(token.location.column == 1)
    }

    @Test("False Token")
    func testFalseToken() throws {
      let tokenizer = Path.Tokenizer("false")
      let token = try tokenizer.nextToken()
      #expect(token.kind == .false)
      #expect(token.location.line == 1)
      #expect(token.location.column == 1)
    }

    @Test("Null Token")
    func testNullToken() throws {
      let tokenizer = Path.Tokenizer("null")
      let token = try tokenizer.nextToken()
      #expect(token.kind == .null)
      #expect(token.location.line == 1)
      #expect(token.location.column == 1)
    }

    @Test("EOF Token")
    func testEofToken() throws {
      let tokenizer = Path.Tokenizer("")
      let token = try tokenizer.nextToken()
      #expect(token.kind == .eof)
      #expect(token.location.line == 1)
      #expect(token.location.column == 1)
    }

    @Test("Whitespace")
    func testWhitespace() throws {
      let tokenizer = Path.Tokenizer("  \t\n  $")
      let token = try tokenizer.nextToken()
      guard case .root(let location) = token else {
        Issue.record("Expected root token")
        return
      }
      #expect(location.line == 2)
      #expect(location.column == 3)
    }

    @Test("Multiple Tokens")
    func testMultipleTokens() throws {
      let tokenizer = Path.Tokenizer("$.name[1:2]")
      let tokens = try [
        tokenizer.nextToken(),
        tokenizer.nextToken(),
        tokenizer.nextToken(),
        tokenizer.nextToken(),
        tokenizer.nextToken(),
        tokenizer.nextToken(),
        tokenizer.nextToken(),
        tokenizer.nextToken(),
      ]

      #expect(tokens[0].kind == .root)
      #expect(tokens[1].kind == .memberAccess)
      #expect(tokens[2].kind == .name)
      #expect(tokens[3].kind == .openBracket)
      #expect(tokens[4].kind == .number)
      #expect(tokens[5].kind == .colon)
      #expect(tokens[6].kind == .number)
      #expect(tokens[7].kind == .closeBracket)
    }

    @Test("String Escapes")
    func testStringEscapes() throws {
      let tokenizer = Path.Tokenizer("\"\\n\\r\\t\\\"\\\\\"")
      let token = try tokenizer.nextToken()
      guard case .string(let value, let quote, _) = token else {
        Issue.record("Expected string token")
        return
      }
      #expect(quote == "\"")
      #expect(value == "\n\r\t\"\\")
    }

    @Test("Unicode Escapes")
    func testUnicodeEscapes() throws {
      let tokenizer = Path.Tokenizer("\"\\u0041\\u0042\"")
      let token = try tokenizer.nextToken()
      guard case .string(let value, let quote, _) = token else {
        Issue.record("Expected string token")
        return
      }
      #expect(quote == "\"")
      #expect(value == "AB")
    }

    @Test("Invalid Token")
    func testInvalidToken() throws {
      let tokenizer = Path.Tokenizer("#")
      #expect(
        throws: Path.ParserError.unexpectedToken("#", location: Path.Tokenizer.Token.Location(line: 1, column: 1))
      ) {
        try tokenizer.nextToken()
      }
    }

    @Test("Invalid String")
    func testInvalidString() throws {
      let tokenizer = Path.Tokenizer("\"unterminated")
      #expect(throws: Path.ParserError.unexpectedEndOfInput) {
        try tokenizer.nextToken()
      }
    }

    @Test("Invalid Escape")
    func testInvalidEscape() throws {
      let tokenizer = Path.Tokenizer("\"\\x\"")
      #expect(
        throws: Path.ParserError
          .invalidEscapeSequence("\\x", location: Path.Tokenizer.Token.Location(line: 1, column: 3))
      ) {
        try tokenizer.nextToken()
      }
    }

    @Test("Invalid Unicode")
    func testInvalidUnicode() throws {
      let tokenizer = Path.Tokenizer("\"\\u123\"")
      #expect(
        throws: Path
          .ParserError.invalidEscapeSequence("\"", location: Path.Tokenizer.Token.Location(line: 1, column: 3))
      ) {
        try tokenizer.nextToken()
      }
    }

    @Test("Invalid Number")
    func testInvalidNumber() throws {
      let tokenizer = Path.Tokenizer("1.2.3")
      #expect(
        throws: Path.ParserError.invalidNumber("1.2.3", location: Path.Tokenizer.Token.Location(line: 1, column: 1))
      ) {
        try tokenizer.nextToken()
      }
    }
  }

}
