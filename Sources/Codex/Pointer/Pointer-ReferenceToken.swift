//
//  Pointer-ReferenceToken.swift
//  Codex
//
//  Created by Kevin Wooten on 1/31/25.
//

extension Pointer {

  /// A reference token in a JSON Pointer.
  ///
  /// Reference tokens are used to navigate through a JSON document's structure.
  /// They can represent object property names, array indices, or the append operation.
  public enum ReferenceToken {
    /// A reference to an object property by name
    case name(String)
    /// A reference to an array element by index
    case index(Int)
    /// A reference to the append position in an array
    case append
  }

}

extension Pointer.ReferenceToken: Sendable {}

extension Pointer.ReferenceToken: Hashable {}
extension Pointer.ReferenceToken: Equatable {}

extension Pointer.ReferenceToken: CustomStringConvertible {

  /// A textual representation of this reference token.
  ///
  /// - For `.name` tokens, returns the name, quoted if it contains special characters
  /// - For `.index` tokens, returns the index as a string
  /// - For `.append` tokens, returns "-"
  public var description: String {
    switch self {
    case .name(let name):
      return if name.contains(#/[/~]/#) {
        "\"\(name)\""
      } else {
        name
      }
    case .index(let index):
      return index.description
    case .append:
      return "-"
    }
  }
}

extension Pointer.ReferenceToken {

  /// Creates a reference token from its encoded string representation, or `nil` if the string is invalid.
  ///
  /// - Parameter string: The encoded string representation
  public init?(encoded string: String) {
    if string == "-" {
      self = .append
    } else if string == "0" || string.first != "0", let index = Int(string, radix: 10) {
      self = .index(index)
    } else {
      self = .name(string.replacingOccurrences(of: "~1", with: "/").replacingOccurrences(of: "~0", with: "~"))
    }
  }

  /// The encoded string representation of this reference token.
  ///
  /// - For `.name` tokens, returns the name with special characters escaped
  /// - For `.index` tokens, returns the index as a string
  /// - For `.append` tokens, returns "-"
  public var encoded: String {
    switch self {
    case .name(let name):
      return name.replacing(#/[~/]/#) { match in
        return switch match.output {
        case "~": "~0"
        case "/": "~1"
        default: fatalError("invalid match")
        }
      }
    case .index(let index):
      return index.description
    case .append:
      return "-"
    }
  }
}

extension Pointer.ReferenceToken {

  /// Creates a reference token from its string representation, throwing an error if invalid.
  ///
  /// - Parameter string: The string representation of the reference token
  /// - Throws: An error if the string is not a valid reference token representation
  public init(validating string: String) throws {
    guard let token = Pointer.ReferenceToken(encoded: string) else {
      throw Pointer.Error.invalidReferenceToken(string)
    }
    self = token
  }

}

extension Pointer.ReferenceToken: ExpressibleByStringLiteral {

  /// Creates a reference token from a string literal.
  ///
  /// - Parameter value: The string literal
  /// - Precondition: The string must be a valid reference token representation
  public init(stringLiteral value: String) {
    guard let token = Self(encoded: value) else {
      fatalError("Invalid string literal for Pointer.ReferenceToken")
    }
    self = token
  }
}

extension Pointer.ReferenceToken: ExpressibleByIntegerLiteral {

  /// Creates a reference token from an integer literal.
  ///
  /// This creates an index token with the given value.
  ///
  /// - Parameter value: The integer literal
  public init(integerLiteral value: Int) {
    self = .index(value)
  }
}
