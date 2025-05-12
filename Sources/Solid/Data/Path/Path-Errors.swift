//
//  Path-Errors.swift
//  SolidFoundation
//
//  Created by Kevin Wooten on 1/28/25.
//

extension Path {

  /// ``Path`` parse errors.
  ///
  public enum ParserError: Swift.Error, Sendable, Equatable {

    /// Details about the location of a token in the input text.
    public struct Location: Equatable, Sendable {

      /// The input line number. `-1` if unknown.
      public let line: Int

      /// The input column number. `-1` if unknown.
      public let column: Int
    }

    /// The parser expected more tokens but reached the end of input.
    /// - Parameters:
    ///  - location: The location of the token in the input.
    case unexpectedEndOfInput

    /// The parser encountered an unexpected token.
    /// - Parameters:
    ///  - token: The unexpected token.
    ///  - location: The location of the token in the input.
    case unexpectedToken(String, location: Location)

    /// The parser encountered an unexpected character.
    /// - Parameters:
    ///  - character: The unexpected character.
    ///  - location: The location of the character in the input.
    case unexpectedCharacter(Character, location: Location)

    /// The parser encountered an invalid number.
    /// - Parameters:
    ///  - number: The invalid number.
    ///  - location: The location of the token in the input.
    case invalidNumber(String, location: Location)

    /// The parser encountered an invalid slice specifier.
    /// - Parameters:
    ///   - slice: The invalid slice specifier.
    ///   - location: The location of the token in the input.
    case invalidSlice(String, location: Location)

    /// The parser encountered an invalid escape sequence in a quoted string.
    /// - Parameters:
    ///  - token: The unexpected token.
    ///  - location: The location of the token in the input.
    case invalidEscapeSequence(String, location: Location)

    /// The parser encountered an unexpected token.
    /// - Parameters:
    ///  - token: The unexpected token.
    ///  - location: The location of the token in the input.
    static func unexpectedToken(_ token: Path.Tokenizer.Token) -> Self {
      .unexpectedToken(token.description, location: token.location)
    }
  }

}
