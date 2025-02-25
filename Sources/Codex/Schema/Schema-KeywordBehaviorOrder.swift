//
//  Schema-KeywordBehaviorOrder.swift
//  Codex
//
//  Created by Kevin Wooten on 2/24/25.
//

extension Schema {

  public struct KeywordBehaviorOrder: RawRepresentable {

    public static let identifiers = Self(-1000)
    public static let references =  Self(-600)
    public static let composites =  Self(-500)
    public static let applicators = Self(-400)
    public static let `default` =   Self(0)
    public static let unevaluated = Self(1000)

    public var rawValue: Int

    public init(_ rawValue: Int) {
      self.rawValue = rawValue
    }

    public init?(rawValue: RawValue) {
      self.init(rawValue)
    }
  }

}

extension Schema.KeywordBehaviorOrder: Sendable {}
extension Schema.KeywordBehaviorOrder: Hashable {}
extension Schema.KeywordBehaviorOrder: Equatable {}

extension Schema.KeywordBehaviorOrder: Comparable {

  public static func < (lhs: Schema.KeywordBehaviorOrder, rhs: Schema.KeywordBehaviorOrder) -> Bool {
    lhs.rawValue < rhs.rawValue
  }

}
