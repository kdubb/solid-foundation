//
//  SchemaType.swift
//  Codex
//
//  Created by Kevin Wooten on 2/4/25.
//

import Foundation

extension Schema {

  public struct InstanceType {

    public var keyword: Schema.Keyword
    public var valueType: ValueType

    public init(keyword: Schema.Keyword, valueType: ValueType) {
      self.keyword = keyword
      self.valueType = valueType
    }

    public static let null = Self(keyword: .null, valueType: .null)
    public static let boolean = Self(keyword: .boolean, valueType: .bool)
    public static let integer = Self(keyword: .integer, valueType: .number)
    public static let number = Self(keyword: .number, valueType: .number)
    public static let bytes = Self(keyword: .bytes, valueType: .bytes)
    public static let string = Self(keyword: .string, valueType: .string)
    public static let array = Self(keyword: .array, valueType: .array)
    public static let object = Self(keyword: .object, valueType: .object)
  }

}

extension Schema.InstanceType: Sendable {}
extension Schema.InstanceType: Hashable {}
extension Schema.InstanceType: Equatable {}

extension Schema.InstanceType: CustomStringConvertible {

  public var description: String { keyword.rawValue }

}
