//
//  Value-Number.swift
//  Codex
//
//  Created by Kevin Wooten on 1/28/25.
//

import BigInt
import BigDecimal

extension Value {

  /// A protocol for numeric values that can be represented in Values.
  ///
  /// This protocol defines the requirements for numeric values that can be used in Values.
  /// It provides methods to convert between different numeric types and properties to
  /// query the characteristics of the number.
  public protocol Number: CustomStringConvertible, Sendable {
    /// The decimal representation of this number.
    var decimal: BigDecimal { get }
    /// Whether this number represents an integer value.
    var isInteger: Bool { get }
    /// Whether this number represents infinity.
    var isInfinity: Bool { get }
    /// Whether this number represents a not-a-number value.
    var isNaN: Bool { get }
    /// Whether this number is negative.
    var isNegative: Bool { get }

    /// Converts this number to a double-precision floating-point value.
    ///
    /// - Returns: The double-precision floating-point representation of this number
    func asDouble() -> Double
    /// Converts this number to a big integer.
    ///
    /// - Returns: The big integer representation of this number
    func asInteger() -> BInt
    /// Converts this number to a Swift integer if possible.
    ///
    /// - Returns: The Swift integer representation of this number, or `nil` if the
    ///   number cannot be represented as a Swift integer
    func asInt() -> Int?
  }

}
