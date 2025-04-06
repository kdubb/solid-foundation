//
//  Value.swift
//  Codex
//
//  Created by Kevin Wooten on 1/28/25.
//

import Foundation
import BigInt
import BigDecimal
import OrderedCollections

public enum Value {

  public typealias Array = Swift.Array<Value>
  public typealias Object = OrderedDictionary<Value, Value>

  case null
  case bool(Bool)
  case number(Number)
  case bytes(Data)
  case string(String)
  case array(Array)
  case object(Object)

}

extension Value: Sendable {}

extension Value: Hashable {

  public func hash(into hasher: inout Hasher) {
    switch self {
    case .null:
      hasher.combine("null")
    case .bool(let value):
      hasher.combine(value)
    case .number(let value):
      switch value {
      case let num as Value.TextNumber:
        hasher.combine(num)
      case let num as Value.BinaryNumber:
        hasher.combine(num)
      default:
        fatalError("Unknown Number type")
      }
    case .string(let value):
      hasher.combine(value)
    case .bytes(let value):
      hasher.combine(value)
    case .array(let value):
      hasher.combine(value)
    case .object(let value):
      hasher.combine(value)
    }
  }

}

extension Value: Equatable {

  public static func == (lhs: Value, rhs: Value) -> Bool {
    switch (lhs, rhs) {
    case (.null, .null):
      return true
    case (.bool(let l), .bool(let r)):
      return l == r
    case (.number(let l), .number(let r)):
      return l.decimal == r.decimal
    case (.string(let l), .string(let r)):
      return l == r
    case (.bytes(let l), .bytes(let r)):
      return l == r
    case (.array(let l), .array(let r)):
      return l == r
    case (.object(let l), .object(let r)):
      return l == r
    default:
      return false
    }
  }
}

extension Value: CustomStringConvertible {

  public var description: String {
    switch self {
    case .null:
      return "null"
    case .bool(let value):
      return value.description
    case .number(let value):
      return value.description
    case .string(let value):
      return "\"\(value)\""
    case .array(let value):
      return "[\(value.map { $0.description }.joined(separator: ", "))]"
    case .object(let value):
      return "{\(value.map { "\($0.description): \($1.description)" }.joined(separator: ", "))}"
    case .bytes(let value):
      return value.base64EncodedString()
    }
  }

}

extension Value {

  public var isNull: Bool {
    guard case .null = self else {
      return false
    }
    return true
  }

  public var array: Array? {
    guard case .array(let array) = self else {
      return nil
    }
    return array
  }

  public var object: Object? {
    guard case .object(let object) = self else {
      return nil
    }
    return object
  }

  public var bool: Bool? {
    guard case .bool(let bool) = self else {
      return nil
    }
    return bool
  }

  public var number: Number? {
    guard case .number(let number) = self else {
      return nil
    }
    return number
  }

  public var integer: BInt? {
    guard let number else {
      return nil
    }
    return number.asInteger()
  }

  public var int: Int? {
    guard let integer else {
      return nil
    }
    return integer.asInt()
  }

  public var string: String? {
    guard case .string(let string) = self else {
      return nil
    }
    return string
  }

  public var bytes: Data? {
    guard case .bytes(let bytes) = self else {
      return nil
    }
    return bytes
  }

  public var stringified: String {
    switch self {
    case .null:
      return "null"
    case .bool(let value):
      return value.description
    case .number(let value):
      return value.description
    case .string(let value):
      return value
    case .array(let value):
      return "[\(value.map { $0.stringified }.joined(separator: ", "))]"
    case .object(let value):
      return "{\(value.map { "\($0): \($1.stringified)" }.joined(separator: ", "))}"
    case .bytes(let value):
      return value.base64EncodedString()
    }
  }

}

extension Value: ExpressibleByNilLiteral {
  public init(nilLiteral: ()) {
    self = .null
  }
}

extension Value: ExpressibleByBooleanLiteral {
  public init(booleanLiteral value: Bool) {
    self = .bool(value)
  }
}

extension Value: ExpressibleByIntegerLiteral {
  public init(integerLiteral value: Int64) {
    self = .number(Value.BinaryNumber.int64(value))
  }
}

extension Value: ExpressibleByFloatLiteral {
  public init(floatLiteral value: Float64) {
    self = .number(Value.BinaryNumber.float64(value))
  }
}

extension Value: ExpressibleByStringLiteral {
  public init(stringLiteral value: String) {
    self = .string(value)
  }
}

extension Value: ExpressibleByArrayLiteral {
  public init(arrayLiteral elements: Value...) {
    self = .array(elements)
  }
}

extension Value: ExpressibleByDictionaryLiteral {
  public init(dictionaryLiteral elements: (Value, Value)...) {
    self = .object(Object(uniqueKeysWithValues: elements))
  }
}

// MARK: - Number Initializers

extension Value {

  public static func number(_ value: Int) -> Value {
    return .number(Value.BinaryNumber.int64(Int64(value)))
  }

  public static func number(_ value: UInt) -> Value {
    return .number(Value.BinaryNumber.uint64(UInt64(value)))
  }

  public static func number(_ value: Int8) -> Value {
    return .number(Value.BinaryNumber.int8(value))
  }

  public static func number(_ value: Int16) -> Value {
    return .number(Value.BinaryNumber.int16(value))
  }

  public static func number(_ value: Int32) -> Value {
    return .number(Value.BinaryNumber.int32(value))
  }

  public static func number(_ value: Int64) -> Value {
    return .number(Value.BinaryNumber.int64(value))
  }

  public static func number(_ value: UInt8) -> Value {
    return .number(Value.BinaryNumber.uint8(value))
  }

  public static func number(_ value: UInt16) -> Value {
    return .number(Value.BinaryNumber.uint16(value))
  }

  public static func number(_ value: UInt32) -> Value {
    return .number(Value.BinaryNumber.uint32(value))
  }

  public static func number(_ value: UInt64) -> Value {
    return .number(Value.BinaryNumber.uint64(value))
  }

  public static func number(_ value: Float16) -> Value {
    return .number(Value.BinaryNumber.float16(value))
  }

  public static func number(_ value: Float32) -> Value {
    return .number(Value.BinaryNumber.float32(value))
  }

  public static func number(_ value: Float64) -> Value {
    return .number(Value.BinaryNumber.float64(value))
  }

  public static func number(_ value: BInt) -> Value {
    return .number(Value.TextNumber(text: value.asString()))
  }

  public static func number(_ value: BigDecimal) -> Value {
    return .number(Value.TextNumber(text: value.asString()))
  }

  public static func number(_ value: String) -> Value {
    assert(!BigDecimal(value).isNaN, "Invalid numeric string")
    return .number(Value.TextNumber(text: value))
  }

}

extension Value {

  public subscript(value: Value) -> Value? {
    get {
      guard case .object(let object) = self else {
        return nil
      }
      return object[value]
    }
    set {
      guard case .object(var object) = self else {
        return
      }
      object[value] = newValue
      self = .object(object)
    }
  }

}
