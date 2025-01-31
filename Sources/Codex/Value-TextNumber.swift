//
//  Value-TextNumber.swift
//  Codex
//
//  Created by Kevin Wooten on 1/28/25.
//

import Foundation
import BigInt
import BigDecimal

extension Value {

  public struct TextNumber {

    public var text: String

    public init(text: String) {
      self.text = text
    }
  }

}

extension Value.TextNumber : Sendable {}

extension Value.TextNumber: Value.Number {

  nonisolated(unsafe) private static let nanRegex = /^[+-]?nan$/.ignoresCase()
  nonisolated(unsafe) private static let infRegex = /^[+-]?inf$/.ignoresCase()
  nonisolated(unsafe) private static let floatRegex = /[.e]/

  public var integer: BInt {
    guard let int = BInt(text, radix: 10) else {
      return .zero
    }
    return int
  }

  public var decimal: BigDecimal {
    return BigDecimal(text.lowercased())
  }

  public var isInteger: Bool {
    return !text.contains(Self.floatRegex)
  }

  public var isNaN: Bool {
    return text.starts(with: Self.nanRegex)
  }

  public var isInfinity: Bool {
    return text.starts(with: Self.infRegex)
  }

}

extension Value.TextNumber: CustomStringConvertible {

  public var description: String { text }

}

extension Value.TextNumber: Hashable {

  public func hash(into hasher: inout Hasher) {
    hasher.combine(text)
  }

}

extension Value.TextNumber: Equatable {

  public static func ==(lhs: Value.TextNumber, rhs: Value.TextNumber) -> Bool {
    lhs.text == rhs.text
  }

}
