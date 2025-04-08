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

/// A JSON like value with support for binary data.
///
/// This enum represents all possible JSON values, including:
/// - `null`: The null value
/// - `bool`: A boolean value
/// - `number`: A numeric value
/// - `bytes`: A binary value
/// - `string`: A string value
/// - `array`: An array of values
/// - `object`: An object mapping values to values
public enum Value {

  /// The type of an array of values.
  public typealias Array = Swift.Array<Value>
  /// The type of an object mapping values to values.
  public typealias Object = OrderedDictionary<Value, Value>

  /// The null value
  case null
  /// A boolean value
  case bool(Bool)
  /// A numeric value
  case number(Number)
  /// A binary value
  case bytes(Data)
  /// A string value
  case string(String)
  /// An array of values
  case array(Array)
  /// An object mapping values to values
  case object(Object)

}

extension Value: Sendable {}

extension Value: Hashable {

  /// Hashes the essential components of this value by feeding them into the given hasher.
  ///
  /// - Parameter hasher: The hasher to use when combining the components of this value
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

  /// Whether this value is null.
  public var isNull: Bool {
    guard case .null = self else {
      return false
    }
    return true
  }

  /// The array value if this value is an array, otherwise nil.
  public var array: Array? {
    guard case .array(let array) = self else {
      return nil
    }
    return array
  }

  /// The object value if this value is an object, otherwise nil.
  public var object: Object? {
    guard case .object(let object) = self else {
      return nil
    }
    return object
  }

  /// The boolean value if this value is a boolean, otherwise nil.
  public var bool: Bool? {
    guard case .bool(let bool) = self else {
      return nil
    }
    return bool
  }

  /// The number value if this value is a number, otherwise nil.
  public var number: Number? {
    guard case .number(let number) = self else {
      return nil
    }
    return number
  }

  /// The big integer value if this value is a number that can be represented as a big integer, otherwise nil.
  public var integer: BInt? {
    guard let number else {
      return nil
    }
    return number.asInteger()
  }

  /// The Swift integer value if this value is a number that can be represented as a Swift integer, otherwise nil.
  public var int: Int? {
    guard let integer else {
      return nil
    }
    return integer.asInt()
  }

  /// The string value if this value is a string, otherwise nil.
  public var string: String? {
    guard case .string(let string) = self else {
      return nil
    }
    return string
  }

  /// The binary data value if this value is binary data, otherwise nil.
  public var bytes: Data? {
    guard case .bytes(let bytes) = self else {
      return nil
    }
    return bytes
  }

  /// A string representation of this value, with strings unquoted.
  ///
  /// This is similar to `description` but with strings unquoted, making it more suitable
  /// for display purposes.
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

  /// Creates a number value from an integer.
  ///
  /// - Parameter value: The integer value
  /// - Returns: A number value representing the integer
  public static func number(_ value: Int) -> Value {
    return .number(Value.BinaryNumber.int64(Int64(value)))
  }

  /// Creates a number value from an unsigned integer.
  ///
  /// - Parameter value: The unsigned integer value
  /// - Returns: A number value representing the unsigned integer
  public static func number(_ value: UInt) -> Value {
    return .number(Value.BinaryNumber.uint64(UInt64(value)))
  }

  /// Creates a number value from an 8-bit integer.
  ///
  /// - Parameter value: The 8-bit integer value
  /// - Returns: A number value representing the 8-bit integer
  public static func number(_ value: Int8) -> Value {
    return .number(Value.BinaryNumber.int8(value))
  }

  /// Creates a number value from a 16-bit integer.
  ///
  /// - Parameter value: The 16-bit integer value
  /// - Returns: A number value representing the 16-bit integer
  public static func number(_ value: Int16) -> Value {
    return .number(Value.BinaryNumber.int16(value))
  }

  /// Creates a number value from a 32-bit integer.
  ///
  /// - Parameter value: The 32-bit integer value
  /// - Returns: A number value representing the 32-bit integer
  public static func number(_ value: Int32) -> Value {
    return .number(Value.BinaryNumber.int32(value))
  }

  /// Creates a number value from a 64-bit integer.
  ///
  /// - Parameter value: The 64-bit integer value
  /// - Returns: A number value representing the 64-bit integer
  public static func number(_ value: Int64) -> Value {
    return .number(Value.BinaryNumber.int64(value))
  }

  /// Creates a number value from an 8-bit unsigned integer.
  ///
  /// - Parameter value: The 8-bit unsigned integer value
  /// - Returns: A number value representing the 8-bit unsigned integer
  public static func number(_ value: UInt8) -> Value {
    return .number(Value.BinaryNumber.uint8(value))
  }

  /// Creates a number value from a 16-bit unsigned integer.
  ///
  /// - Parameter value: The 16-bit unsigned integer value
  /// - Returns: A number value representing the 16-bit unsigned integer
  public static func number(_ value: UInt16) -> Value {
    return .number(Value.BinaryNumber.uint16(value))
  }

  /// Creates a number value from a 32-bit unsigned integer.
  ///
  /// - Parameter value: The 32-bit unsigned integer value
  /// - Returns: A number value representing the 32-bit unsigned integer
  public static func number(_ value: UInt32) -> Value {
    return .number(Value.BinaryNumber.uint32(value))
  }

  /// Creates a number value from a 64-bit unsigned integer.
  ///
  /// - Parameter value: The 64-bit unsigned integer value
  /// - Returns: A number value representing the 64-bit unsigned integer
  public static func number(_ value: UInt64) -> Value {
    return .number(Value.BinaryNumber.uint64(value))
  }

  /// Creates a number value from a 16-bit floating-point number.
  ///
  /// - Parameter value: The 16-bit floating-point value
  /// - Returns: A number value representing the 16-bit floating-point number
  public static func number(_ value: Float16) -> Value {
    return .number(Value.BinaryNumber.float16(value))
  }

  /// Creates a number value from a 32-bit floating-point number.
  ///
  /// - Parameter value: The 32-bit floating-point value
  /// - Returns: A number value representing the 32-bit floating-point number
  public static func number(_ value: Float32) -> Value {
    return .number(Value.BinaryNumber.float32(value))
  }

  /// Creates a number value from a 64-bit floating-point number.
  ///
  /// - Parameter value: The 64-bit floating-point value
  /// - Returns: A number value representing the 64-bit floating-point number
  public static func number(_ value: Float64) -> Value {
    return .number(Value.BinaryNumber.float64(value))
  }

  /// Creates a number value from a big integer.
  ///
  /// - Parameter value: The big integer value
  /// - Returns: A number value representing the big integer
  public static func number(_ value: BInt) -> Value {
    return .number(Value.TextNumber(text: value.asString()))
  }

  /// Creates a number value from a big decimal.
  ///
  /// - Parameter value: The big decimal value
  /// - Returns: A number value representing the big decimal
  public static func number(_ value: BigDecimal) -> Value {
    return .number(Value.TextNumber(text: value.asString()))
  }

  /// Creates a number value from a string representation of a number.
  ///
  /// - Parameter value: The string representation of the number
  /// - Returns: A number value representing the number
  /// - Precondition: The string must represent a valid number
  public static func number(_ value: String) -> Value {
    assert(!BigDecimal(value).isNaN, "Invalid numeric string")
    return .number(Value.TextNumber(text: value))
  }

}

extension Value {

  /// Accesses or modifies the value associated with the given key in an object.
  ///
  /// - Parameter value: The key to look up
  /// - Returns: The value associated with the key, or nil if the key is not found
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
