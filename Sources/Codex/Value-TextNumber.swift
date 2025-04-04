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

    public let text: String
    public let decimal: BigDecimal

    private init(text: String, decimal: BigDecimal) {
      self.text = text
      self.decimal = decimal
    }

    public init(text: String) {
      self = Self(text: text, decimal: BigDecimal(text))
    }

    public init(decimal: BigDecimal) {
      self = Self(text: decimal.asString(), decimal: decimal)
    }
  }

}

extension Value.TextNumber : Sendable {}

extension Value.TextNumber: Value.Number {

  public var isInteger: Bool {
    let decimal = self.decimal
    return decimal.rounded() == decimal
  }

  public func asDouble() -> Double {
    return decimal.asDouble()
  }

  public func asInteger() -> BInt {
    return decimal.withExponent(0, .towardZero).digits
  }

  public func asInt() -> Int? {
    return asInteger().asInt()
  }

  public var isNaN: Bool {
    return decimal.isNaN
  }

  public var isInfinity: Bool {
    return decimal.isInfinite
  }

  public var isNegative: Bool {
    return decimal.sign == .minus
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
