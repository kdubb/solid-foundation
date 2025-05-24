//
//  AnyComponent.swift
//  SolidFoundation
//
//  Created by Kevin Wooten on 4/28/25.
//

import Foundation


public struct AnyComponent: Component {

  public struct Value {

    private nonisolated(unsafe) let hashable: AnyHashable

    public init(_ value: some Equatable & Hashable & Sendable) {
      self.hashable = .init(value)
    }

  }

  public let component: any Component
  public var id: ComponentId { component.id }
  public var name: String { component.name }
  public var unit: Unit { component.unit }

  private let validator: @Sendable (Value) throws -> Void
  private let isValidChecker: @Sendable (Value) -> Bool

  public init<C>(_ component: C) where C: Component {
    self.component = component
    self.validator = {
      guard let other = $0 as? C.Value else {
        throw TempoError.invalidComponentValue(component: component.name, reason: .extended(reason: "Invalid type"))
      }
      try component.validate(other)
    }
    self.isValidChecker = {
      guard let other = $0 as? C.Value else { return false }
      return component.isValid(other)
    }
  }

  public func validate(_ value: Value) throws {
    try validator(value)
  }

  public func isValid(_ value: Value) -> Bool {
    isValidChecker(value)
  }

}

extension AnyComponent: Equatable {

  public static func == (lhs: AnyComponent, rhs: AnyComponent) -> Bool {
    return lhs.id == rhs.id
  }

}

extension AnyComponent: Hashable {

  public func hash(into hasher: inout Hasher) {
    hasher.combine(id)
  }

}

extension AnyComponent: Comparable {

  public static func < (lhs: Self, rhs: Self) -> Bool {
    return lhs.id < rhs.id
  }

}

extension AnyComponent: Sendable {}

extension AnyComponent.Value: Equatable {

  public static func == (lhs: Self, rhs: Self) -> Bool {
    return lhs.hashable == rhs.hashable
  }

}

extension AnyComponent.Value: Hashable {

  public func hash(into hasher: inout Hasher) {
    hashable.hash(into: &hasher)
  }

}

extension AnyComponent.Value: Sendable {}

extension Component {

  public var any: AnyComponent {
    .init(self)
  }

}

extension Sequence where Element == any Component {

  public var anys: some Sequence<AnyComponent> {
    map { $0.any }
  }

}
