//
//  JSONReader.swift
//  Codex
//
//  Created by Kevin Wooten on 2/25/25.
//

import Foundation
import BigDecimal

public struct JSONValueReader {

  let tokenReader: JSONTokenReader

  public init(data: Data) {
    self.tokenReader = JSONTokenReader(data: data)
  }

  public init(string: String) {
    self.tokenReader = JSONTokenReader(string: string)
  }

  public func readValue() throws -> Value {
    return try tokenReader.readValue(converter: Converter.instance)
  }

  enum Converter: JSONTokenConverter {

    case instance

    typealias ValueType = Codex.Value

    func convertScalar(_ value: JSONToken.Scalar) throws -> Value {
      switch value {
      case .string(let string): .string(string)
      case .number(let number): .number(BigDecimal(number.value))
      case .bool(let bool): .bool(bool)
      case .null: .null
      }
    }

    func convertArray(_ value: [Value]) throws -> Value {
      return .array(value)
    }

    func convertObject(_ value: [String : Value]) throws -> Value {
      return .object(Value.Object(uniqueKeysWithValues: value.map { (.string($0.key), $0.value) }))
    }

    func convertNull() -> Value {
      return .null
    }
  }
}
