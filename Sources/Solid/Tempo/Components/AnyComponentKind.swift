//
//  AnyComponentKind.swift
//  SolidFoundation
//
//  Created by Kevin Wooten on 4/28/25.
//

import Foundation


public struct AnyComponentKind: ComponentKind {

  public struct Value {

    private nonisolated(unsafe) let hashable: AnyHashable

    public init(_ value: some Equatable & Hashable & Sendable) {
      self.hashable = .init(value)
    }

  }

  public let wrapped: any ComponentKind

  public var id: ComponentId { wrapped.id }
  public var name: String { wrapped.name }
  public var unit: Unit { wrapped.unit }

  private let validator: @Sendable (Value) throws -> Void
  private let isValidChecker: @Sendable (Value) -> Bool

  public init<K>(_ wrapped: K) where K: ComponentKind {
    self.wrapped = wrapped
    self.validator = {
      guard let other = $0 as? K.Value else {
        throw TempoError.invalidComponentValue(component: wrapped.id, reason: .extended(reason: "Invalid type"))
      }
      try wrapped.validate(other)
    }
    self.isValidChecker = {
      guard let other = $0 as? K.Value else { return false }
      return wrapped.isValid(other)
    }
  }

  public func validate(_ value: Value) throws {
    try validator(value)
  }

  public func isValid(_ value: Value) -> Bool {
    isValidChecker(value)
  }

}

extension AnyComponentKind: Equatable {

  public static func == (lhs: AnyComponentKind, rhs: AnyComponentKind) -> Bool {
    return lhs.id == rhs.id
  }

}

extension AnyComponentKind: Hashable {

  public func hash(into hasher: inout Hasher) {
    hasher.combine(id)
  }

}

extension AnyComponentKind: Comparable {

  public static func < (lhs: Self, rhs: Self) -> Bool {
    return lhs.id < rhs.id
  }

}

extension AnyComponentKind: Sendable {}

extension AnyComponentKind.Value: Equatable {

  public static func == (lhs: Self, rhs: Self) -> Bool {
    return lhs.hashable == rhs.hashable
  }

}

extension AnyComponentKind.Value: Hashable {

  public func hash(into hasher: inout Hasher) {
    hashable.hash(into: &hasher)
  }

}

extension AnyComponentKind.Value: Sendable {}

extension ComponentKind {

  public var any: AnyComponentKind {
    .init(self)
  }

}

extension Sequence where Element == any ComponentKind {

  public var anys: some Sequence<AnyComponentKind> {
    map { $0.any }
  }

}
