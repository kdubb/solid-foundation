//
//  Path-Tokenizer.swift
//  SolidFoundation
//
//  Created by Kevin Wooten on 1/28/25.
//

import SolidCore
import SolidNumeric
import Foundation

extension Path {

  class Tokenizer: TokenStream {

    enum Token: Equatable, CustomStringConvertible, Sendable {

      typealias Location = ParserError.Location

      enum Kind: Equatable, Sendable {
        case root
        case current
        case memberAccess
        case descendantAccess
        case wildcard
        case filter
        case colon
        case semicolon
        case openBracket
        case closeBracket
        case openParen
        case closeParen
        case comma
        case exclamation
        case logicalAnd
        case logicalOr
        case comparisonOp
        case name
        case number
        case string
        case `true`
        case `false`
        case `null`
        case eof
      }

      case root(location: Location)
      case current(location: Location)
      case memberAccess(location: Location)
      case descendantAccess(location: Location)
      case wildcard(location: Location)
      case filter(location: Location)
      case colon(location: Location)
      case semicolon(location: Location)
      case openBracket(location: Location)
      case closeBracket(location: Location)
      case openParen(location: Location)
      case closeParen(location: Location)
      case comma(location: Location)
      case exclamation(location: Location)
      case logicalAnd(location: Location)
      case logicalOr(location: Location)
      case comparisonOp(Path.Selector.Expression.ComparisonOperator, location: Location)
      case name(String, location: Location)
      case number(BigDecimal, location: Location)
      case string(String, quote: Character?, location: Location)
      case `true`(location: Location)
      case `false`(location: Location)
      case `null`(location: Location)
      case eof(location: Location)

      func isOneOf(_ kind: Kind...) -> Bool {
        return kind.contains(self.kind)
      }

      var kind: Kind {
        switch self {
        case .root: return .root
        case .current: return .current
        case .memberAccess: return .memberAccess
        case .descendantAccess: return .descendantAccess
        case .wildcard: return .wildcard
        case .filter: return .filter
        case .colon: return .colon
        case .semicolon: return .semicolon
        case .openBracket: return .openBracket
        case .closeBracket: return .closeBracket
        case .openParen: return .openParen
        case .closeParen: return .closeParen
        case .comma: return .comma
        case .exclamation: return .exclamation
        case .logicalAnd: return .logicalAnd
        case .logicalOr: return .logicalOr
        case .comparisonOp: return .comparisonOp
        case .name: return .name
        case .number: return .number
        case .string: return .string
        case .true: return .true
        case .false: return .false
        case .null: return .null
        case .eof: return .eof
        }
      }

      var description: String {
        switch self {
        case .root: return "$"
        case .current: return "@"
        case .memberAccess: return "."
        case .descendantAccess: return ".."
        case .wildcard: return "*"
        case .filter: return "?"
        case .colon: return ":"
        case .semicolon: return ";"
        case .openBracket: return "["
        case .closeBracket: return "]"
        case .openParen: return "("
        case .closeParen: return ")"
        case .comma: return ","
        case .exclamation: return "!"
        case .logicalAnd: return "&"
        case .logicalOr: return "|"
        case .comparisonOp(let op, _): return op.rawValue
        case .name(let name, _): return name
        case .number(let number, _): return String(number)
        case .string(let s, let q, _): return "\(q.map(String.init) ?? "")\(s)\(q.map(String.init) ?? "")"
        case .true: return "true"
        case .false: return "false"
        case .null: return "null"
        case .eof: return "EOF"
        }
      }

      var location: Location {
        switch self {
        case .root(let location): return location
        case .current(let location): return location
        case .memberAccess(let location): return location
        case .descendantAccess(let location): return location
        case .wildcard(let location): return location
        case .filter(let location): return location
        case .colon(let location): return location
        case .semicolon(let location): return location
        case .openBracket(let location): return location
        case .closeBracket(let location): return location
        case .openParen(let location): return location
        case .closeParen(let location): return location
        case .comma(let location): return location
        case .exclamation(let location): return location
        case .logicalAnd(let location): return location
        case .logicalOr(let location): return location
        case .comparisonOp(_, let location): return location
        case .name(_, let location): return location
        case .number(_, let location): return location
        case .string(_, _, let location): return location
        case .true(let location): return location
        case .false(let location): return location
        case .null(let location): return location
        case .eof(let location): return location
        }
      }
    }

    enum ComparisonOperator: String {
      case eq = "=="
      case ne = "!="
      case gt = ">"
      case ge = ">="
      case lt = "<"
      case le = "<="
    }

    private let input: String
    private var index: String.Index
    private var currentLine: Int
    private var currentColumn: Int

    init(_ input: String) {
      self.input = input
      self.index = input.startIndex
      self.currentLine = 1
      self.currentColumn = 1
    }

    var currentLocation: Token.Location {
      get { Token.Location(line: currentLine, column: currentColumn) }
      set {
        currentLine = newValue.line
        currentColumn = newValue.column
      }
    }

    func nextToken() throws(ParserError) -> Token {
      consumeWhitespace()

      guard let char = peek() else {
        return .eof(location: currentLocation)
      }

      let location = currentLocation

      switch char {
      case "$":
        _ = advance()
        return .root(location: location)

      case "@":
        _ = advance()
        return .current(location: location)

      case ".":
        _ = advance()
        if match(".") {
          return .descendantAccess(location: location)
        }
        return .memberAccess(location: location)

      case "*":
        _ = advance()
        return .wildcard(location: location)

      case "?":
        _ = advance()
        return .filter(location: location)

      case ":":
        _ = advance()
        return .colon(location: location)

      case ";":
        _ = advance()
        return .semicolon(location: location)

      case "[":
        _ = advance()
        return .openBracket(location: location)

      case "]":
        _ = advance()
        return .closeBracket(location: location)

      case "(":
        _ = advance()
        return .openParen(location: location)

      case ")":
        _ = advance()
        return .closeParen(location: location)

      case ",":
        _ = advance()
        return .comma(location: location)

      case "!":
        _ = advance()
        if match("=") {
          return .comparisonOp(.ne, location: location)
        }
        return .exclamation(location: location)

      case "&":
        _ = advance()
        try consume("&")
        return .logicalAnd(location: location)

      case "|":
        _ = advance()
        try consume("|")
        return .logicalOr(location: location)

      case "=":
        _ = advance()
        try consume("=")
        return .comparisonOp(.eq, location: location)

      case ">":
        _ = advance()
        if match("=") {
          return .comparisonOp(.ge, location: location)
        }
        return .comparisonOp(.gt, location: location)

      case "<":
        _ = advance()
        if match("=") {
          return .comparisonOp(.le, location: location)
        }
        return .comparisonOp(.lt, location: location)

      case "\"":
        _ = advance()
        let string = try parseStringLiteral("\"")
        try consume("\"")
        return .string(string, quote: "\"", location: location)

      case "'":
        _ = advance()
        let string = try parseStringLiteral("'")
        try consume("'")
        return .string(string, quote: "'", location: location)

      case "0"..."9", "-":
        let number = try parseNumber()
        return .number(number, location: location)

      default:
        if isNameChar(char) {
          let name = try parseName()
          switch name {
          case "true": return .true(location: location)
          case "false": return .false(location: location)
          case "null": return .null(location: location)
          default: return .name(name, location: location)
          }
        }
        throw ParserError.unexpectedToken(String(char), location: currentLocation)
      }
    }

    private func parseStringLiteral(_ quote: Character) throws(ParserError) -> String {
      var string = ""
      while let char = peek(), char != quote {
        if match("\\") {
          string.append(try parseEscapeSequence())
        } else {
          _ = advance()
          string.append(char)
        }
      }
      return string
    }

    private func parseEscapeSequence() throws(ParserError) -> Character {
      let startLocation = currentLocation
      let startIndex = index

      if let char = advance() {
        switch char {
        case "b": return "\u{8}"
        case "f": return "\u{C}"
        case "n": return "\n"
        case "r": return "\r"
        case "t": return "\t"
        case "\"": return "\""
        case "'": return "'"
        case "\\": return "\\"
        case "u":
          let hex1 = try parseHexDigit(startLocation: startLocation)
          let hex2 = try parseHexDigit(startLocation: startLocation)
          let hex3 = try parseHexDigit(startLocation: startLocation)
          let hex4 = try parseHexDigit(startLocation: startLocation)
          let code = (hex1 << 12) | (hex2 << 8) | (hex3 << 4) | hex4
          guard let scalar = UnicodeScalar(code) else {
            let chars = String(input[startIndex...index])
            throw ParserError.invalidEscapeSequence(chars, location: startLocation)
          }
          return Character(scalar)
        default:
          throw ParserError.invalidEscapeSequence("\\\(char)", location: startLocation)
        }
      }
      throw .unexpectedEndOfInput
    }

    private func parseHexDigit(startLocation: Token.Location) throws(ParserError) -> Int {
      guard let char = advance() else {
        throw .unexpectedEndOfInput
      }
      return switch char {
      case "0"..."9":
        Int(
          char.unicodeScalars[char.unicodeScalars.startIndex].value
            - "0".unicodeScalars[char.unicodeScalars.startIndex].value
        )
      case "a"..."f":
        Int(
          char.unicodeScalars[char.unicodeScalars.startIndex].value
            - "a".unicodeScalars[char.unicodeScalars.startIndex].value
        ) + 10
      case "A"..."F":
        Int(
          char.unicodeScalars[char.unicodeScalars.startIndex].value
            - "A".unicodeScalars[char.unicodeScalars.startIndex].value
        ) + 10
      default:
        throw .invalidEscapeSequence(String(char), location: startLocation)
      }
    }

    private func parseNumber() throws(ParserError) -> BigDecimal {
      let startLocation = currentLocation

      var numberStr = ""
      if match("-") {
        numberStr += "-"
      }
      while let char = peek(), isDigit(char) || char == "." {
        numberStr.append(char)
        _ = advance()
      }

      guard let number = BigDecimal(numberStr) else {
        throw .invalidNumber(numberStr, location: startLocation)
      }
      return number
    }

    private func parseName() throws(ParserError) -> String {
      let startLocation = currentLocation
      let startIndex = index

      var name = ""
      while let next = peek(), isNameChar(next), let char = advance() {
        name.append(char)
      }
      guard !name.isEmpty else {
        throw ParserError.unexpectedToken(String(input[startIndex..<index]), location: startLocation)
      }
      return name
    }

    private func consumeWhitespace() {
      while let char = peek(), isWhitespace(char) {
        _ = advance()
      }
    }

    private func match(_ expected: String) -> Bool {
      let startIndex = index
      let startLocation = currentLocation

      for char in expected {
        guard peek() == char else {
          reset(to: startIndex, location: startLocation)
          return false
        }
        _ = advance()
      }

      return true
    }

    private func consume(_ expected: String) throws(ParserError) {
      guard match(expected) else {
        guard let char = peek() else { throw .unexpectedEndOfInput }
        throw .unexpectedCharacter(char, location: currentLocation)
      }
    }

    private func reset(to prevIndex: String.Index, location prevLocation: Token.Location) {
      index = prevIndex
      currentLocation = prevLocation
    }

    private func peek() -> Character? {
      guard index < input.endIndex else { return nil }
      return input[index]
    }

    private func advance() -> Character? {
      guard index < input.endIndex else { return nil }
      let char = input[index]
      index = input.index(after: index)
      if char == "\n" {
        currentLine += 1
        currentColumn = 1
      } else {
        currentColumn += 1
      }
      return char
    }

    private func isWhitespace(_ char: Character) -> Bool {
      char == " " || char == "\t" || char == "\n" || char == "\r"
    }

    private func isDigit(_ char: Character) -> Bool {
      char >= "0" && char <= "9"
    }

    private func isNameChar(_ char: Character) -> Bool {
      char.isLetter || char.isNumber || char == "_" || char == "-"
    }
  }
}
