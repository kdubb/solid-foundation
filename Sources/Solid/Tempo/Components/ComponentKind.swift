//
//  ComponentKind.swift
//  SolidFoundation
//
//  Created by Kevin Wooten on 4/28/25.
//

import Foundation

public protocol ComponentKind<Value>: Equatable, Hashable, Sendable {

  typealias Id = ComponentId
  associatedtype Value: Equatable & Hashable & Sendable

  var id: Id { get }
  var name: String { get }
  var errorName: String { get }
  var unit: Unit { get }

  func validate(_ value: Value) throws
  func isValid(_ value: Value) -> Bool
}

extension ComponentKind {

  public var name: String { id.name }
  public var errorName: String { id.errorName }

  public static func `for`(id: String) -> Self {
    guard let kind = ComponentId(rawValue: id)?.kind as? Self else {
      fatalError("ComponentKind with id \(id) not found")
    }
    return kind
  }

  public static func == (lhs: Self, rhs: Self) -> Bool {
    lhs.id == rhs.id
  }

  public func hash(into hasher: inout Hasher) {
    hasher.combine(id)
  }

  public func isValid(_ value: Value) -> Bool {
    do {
      try validate(value)
      return true
    } catch {
      return false
    }
  }

}

public func ~= (lhs: some ComponentKind, rhs: some ComponentKind) -> Bool { lhs.id == rhs.id }

extension Sequence where Element == any ComponentKind {

  public func contains(_ kind: any ComponentKind) -> Bool { contains { $0.id == kind.id } }

}

extension Sequence where Element: ComponentKind {

  public func contains(_ kind: any ComponentKind) -> Bool { contains { $0.id == kind.id } }

}
