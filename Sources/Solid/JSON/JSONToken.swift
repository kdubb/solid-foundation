//
//  JSONToken.swift
//  SolidFoundation
//
//  Created by Kevin Wooten on 2/25/24.
//

import Foundation

enum JSONToken: Equatable {

  public enum Scalar: Equatable {

    public enum Kind: Equatable {
      case string
      case number
      case bool
      case null
    }

    public struct Number: Equatable, Hashable, Codable {

      public var value: String
      public var isInteger: Bool
      public var isNegative: Bool

      public init(_ value: String, isInteger: Bool, isNegative: Bool) {
        self.value = value
        self.isInteger = isInteger
        self.isNegative = isNegative
      }

      public init(_ value: String) {
        self.init(value, isInteger: value.allSatisfy { $0.isNumber || $0 == "-" }, isNegative: value.hasPrefix("-"))
      }

      public init(_ value: Value.Number) {
        self.init(value.description, isInteger: value.isInteger, isNegative: value.isNegative)
      }

      public init<T: FloatingPoint>(_ value: T) {
        self.value = String(describing: value)
        isInteger = false
        isNegative = value < 0
      }

      public init<T: SignedInteger>(_ value: T) {
        self.value = String(value)
        isInteger = true
        isNegative = value < 0
      }

      public init<T: UnsignedInteger>(_ value: T) {
        self.value = String(value)
        isInteger = true
        isNegative = false
      }

    }

    case string(String)
    case number(Number)
    case bool(Bool)
    case null

    public var kind: Kind {
      switch self {
      case .string: .string
      case .number: .number
      case .bool: .bool
      case .null: .null
      }
    }
  }

  public enum Kind: Equatable {
    case scalar
    case beginArray
    case endArray
    case beginObject
    case endObject
    case pairSeparator
    case elementSeparator
  }

  case scalar(Scalar)
  case beginArray
  case endArray
  case beginObject
  case endObject
  case pairSeparator
  case elementSeparator

  public var kind: Kind {
    switch self {
    case .scalar: .scalar
    case .beginArray: .beginArray
    case .endArray: .endArray
    case .beginObject: .beginObject
    case .endObject: .endObject
    case .pairSeparator: .pairSeparator
    case .elementSeparator: .elementSeparator
    }
  }

}
