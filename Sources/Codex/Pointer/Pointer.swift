//
//  Pointer.swift
//  Codex
//
//  Created by Kevin Wooten on 1/31/25.
//

public struct Pointer {

  public typealias ReferenceTokens = Array<ReferenceToken>

  public let tokens: ReferenceTokens

  public init<S: Sequence>(tokens: S) where S.Element == ReferenceToken {
    self.tokens = Array(tokens)
  }

  public init(tokens: ReferenceToken...) {
    self.tokens = tokens
  }

  var parent: Pointer {
    dropping(count: 1)
  }

  public func dropping(count: Int) -> Pointer {
    Pointer(tokens: Array(tokens.dropLast(count)))
  }

  public func appending(tokens: ReferenceTokens) -> Pointer {
    Pointer(tokens: self.tokens + tokens)
  }

  public func appending(tokens: ReferenceToken...) -> Pointer {
    appending(tokens: tokens)
  }

  public func appending(pointer: Pointer) -> Pointer {
    appending(tokens: pointer.tokens)
  }

  public func appending(string: String) throws -> Pointer {
    appending(pointer: try Pointer(validating: string))
  }

  public static let root = Pointer(tokens: [])

}

extension Pointer : Sendable {}

extension Pointer : Hashable {}
extension Pointer : Equatable {}

extension Pointer : CustomStringConvertible {

  public var description: String {
    "/\(tokens.map(\.description).joined(separator: "/"))"
  }
}

extension Pointer {

  public init?(encoded string: String) {
    var tokens: [ReferenceToken] = []
    if string == "/" {
      tokens = [.name("")]
    } else {
      for tokenString in string.split(separator: "/") {
        guard let token = ReferenceToken(encoded: String(tokenString)) else {
          return nil
        }
        tokens.append(token)
      }
    }
    self.tokens = tokens
  }

  public var encoded: String {
    "/\(tokens.map(\.encoded).joined(separator: "/"))"
  }

}

extension Pointer {

  public init(validating string: String) throws {
    self.tokens = try string.split(separator: "/")
      .map { try ReferenceToken(validating: String($0)) }
  }

  public init(valid string: String) {
    guard let pointer = Pointer(encoded: string) else {
      fatalError("Invalid pointer")
    }
    self = pointer
  }

}

extension Pointer : ExpressibleByStringLiteral {

  public init(stringLiteral value: String) {
    if value.contains("/") {
      guard let pointer = Pointer(encoded: value) else {
        fatalError("Invalid Pointer string literal")
      }
      self = pointer
    } else {
      self = Pointer(tokens: [.name(value)])
    }
  }

}

extension Pointer : ExpressibleByIntegerLiteral {

  public init(integerLiteral value: Int) {
    self = Pointer(tokens: [.index(value)])
  }

}

extension Pointer : Sequence {

  public func makeIterator() -> ReferenceTokens.Iterator {
    tokens.makeIterator()
  }

}

public func /(lhs: Pointer, rhs: Pointer) -> Pointer {
  Pointer(tokens: lhs.tokens + rhs.tokens)
}
