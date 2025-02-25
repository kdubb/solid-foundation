//
//  Value-BinaryNumber.swift
//  Codex
//
//  Created by Kevin Wooten on 1/28/25.
//

import Foundation
import BigInt
import BigDecimal

extension Value {

  public enum BinaryNumber {
    case int8(Int8)
    case int16(Int16)
    case int32(Int32)
    case int64(Int64)
    case uint8(UInt8)
    case uint16(UInt16)
    case uint32(UInt32)
    case uint64(UInt64)
    case float16(Float16)
    case float32(Float32)
    case float64(Float64)
  }

}

extension Value.BinaryNumber : Sendable {}

extension Value.BinaryNumber : Value.Number {

  public var decimal: BigDecimal {
    switch self {
    case .int8(let value): BigDecimal(value)
    case .int16(let value): BigDecimal(value)
    case .int32(let value): BigDecimal(value)
    case .int64(let value): BigDecimal(value)
    case .uint8(let value): BigDecimal(value)
    case .uint16(let value): BigDecimal(value)
    case .uint32(let value): BigDecimal(value)
    case .uint64(let value): BigDecimal(value)
    case .float16(let value): BigDecimal(Float64(value))
    case .float32(let value): BigDecimal(Float64(value))
    case .float64(let value): BigDecimal(value)
    }
  }

  public var isInteger: Bool {
    switch self {
    case .int8, .int16, .int32, .int64:
      return true
    default:
      return false
    }
  }

  public var isNaN: Bool {
    switch self {
    case .float16(let value): value.isNaN
    case .float32(let value): value.isNaN
    case .float64(let value): value.isNaN
    default: false
    }
  }

  public var isInfinity: Bool {
    switch self {
    case .float16(let value): value.isInfinite
    case .float32(let value): value.isInfinite
    case .float64(let value): value.isInfinite
    default: false
    }
  }

  public var isNegative: Bool {
    return decimal.isNegative
  }

  public func asInteger() -> BInt? {
    switch self {
    case .int8(let value): BInt(value)
    case .int16(let value): BInt(value)
    case .int32(let value): BInt(value)
    case .int64(let value): BInt(value)
    case .uint8(let value): BInt(value)
    case .uint16(let value): BInt(value)
    case .uint32(let value): BInt(value)
    case .uint64(let value): BInt(value)
    default: decimal.digits
    }
  }

  public func asInt() -> Int? {
    switch self {
    case .int8(let value): Int(value)
    case .int16(let value): Int(value)
    case .int32(let value): Int(value)
    case .int64(let value): Int(value)
    case .uint8(let value): Int(value)
    case .uint16(let value): Int(value)
    case .uint32(let value): Int(value)
    case .uint64(let value): if value < Int64.max { Int(value) } else { nil }
    default: decimal.asInt()
    }
  }

  public func asDouble() -> Double {
    decimal.asDouble()
  }

}

extension Value.BinaryNumber: CustomStringConvertible {

  private static let cLocale = Locale(identifier: "C")

  public var description: String {
    switch self {
    case .int8(let value): value.formatted(.number.locale(Self.cLocale))
    case .int16(let value): value.formatted(.number.locale(Self.cLocale))
    case .int32(let value): value.formatted(.number.locale(Self.cLocale))
    case .int64(let value): value.formatted(.number.locale(Self.cLocale))
    case .uint8(let value): value.formatted(.number.locale(Self.cLocale))
    case .uint16(let value): value.formatted(.number.locale(Self.cLocale))
    case .uint32(let value): value.formatted(.number.locale(Self.cLocale))
    case .uint64(let value): value.formatted(.number.locale(Self.cLocale))
    case .float16(let value): value.formatted(.number.locale(Self.cLocale))
    case .float32(let value): value.formatted(.number.locale(Self.cLocale))
    case .float64(let value): value.formatted(.number.locale(Self.cLocale))
    }
  }
}

extension Value.BinaryNumber: Hashable {

  public func hash(into hasher: inout Hasher) {
    switch self {
    case .int8(let value):
      hasher.combine(value)
    case .int16(let value):
      hasher.combine(value)
    case .int32(let value):
      hasher.combine(value)
    case .int64(let value):
      hasher.combine(value)
    case .uint8(let value):
      hasher.combine(value)
    case .uint16(let value):
      hasher.combine(value)
    case .uint32(let value):
      hasher.combine(value)
    case .uint64(let value):
      hasher.combine(value)
    case .float16(let value):
      hasher.combine(value)
    case .float32(let value):
      hasher.combine(value)
    case .float64(let value):
      hasher.combine(value)
    }
  }

}

extension Value.BinaryNumber: Equatable {

  public static func ==(lhs: Value.BinaryNumber, rhs: Value.BinaryNumber) -> Bool {
    switch (lhs, rhs) {
    case (.int8(let l), .int8(let r)):
      return l == r
    case (.int16(let l), .int16(let r)):
      return l == r
    case (.int32(let l), .int32(let r)):
      return l == r
    case (.int64(let l), .int64(let r)):
      return l == r
    case (.uint8(let l), .uint8(let r)):
      return l == r
    case (.uint16(let l), .uint16(let r)):
      return l == r
    case (.uint32(let l), .uint32(let r)):
      return l == r
    case (.uint64(let l), .uint64(let r)):
      return l == r
    case (.float16(let l), .float16(let r)):
      return l == r
    case (.float32(let l), .float32(let r)):
      return l == r
    case (.float64(let l), .float64(let r)):
      return l == r
    default:
      return false
    }
  }
}
