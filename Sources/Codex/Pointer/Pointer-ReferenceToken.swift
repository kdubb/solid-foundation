//
//  Pointer-ReferenceToken.swift
//  Codex
//
//  Created by Kevin Wooten on 1/31/25.
//

extension Pointer {

  public enum ReferenceToken {
    case name(String)
    case index(Int)
    case append
  }

}

extension Pointer.ReferenceToken: Sendable {}

extension Pointer.ReferenceToken: Hashable {}
extension Pointer.ReferenceToken: Equatable {}

extension Pointer.ReferenceToken: CustomStringConvertible {

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

  public init?(encoded string: String) {
    if string == "-" {
      self = .append
    } else if string == "0" || string.first != "0", let index = Int(string, radix: 10) {
      self = .index(index)
    } else {
      self = .name(string.replacingOccurrences(of: "~1", with: "/").replacingOccurrences(of: "~0", with: "~"))
    }
  }

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
      return "\(index)"
    case .append:
      return "-"
    }
  }
}

extension Pointer.ReferenceToken {

  public init(validating string: String) throws {
    guard let token = Pointer.ReferenceToken(encoded: string) else {
      throw Pointer.Error.invalidReferenceToken(string)
    }
    self = token
  }

}

extension Pointer.ReferenceToken: ExpressibleByStringLiteral {

  public init(stringLiteral value: String) {
    guard let token = Self(encoded: value) else {
      fatalError("Invalid string literal for Pointer.ReferenceToken")
    }
    self = token
  }
}

extension Pointer.ReferenceToken: ExpressibleByIntegerLiteral {

  public init(integerLiteral value: Int) {
    self = .index(value)
  }
}
