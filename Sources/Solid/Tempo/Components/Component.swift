//
//  Component.swift
//  SolidFoundation
//
//  Created by Kevin Wooten on 4/28/25.
//

import Foundation

public protocol Component<Value>: Equatable, Hashable, Sendable {
  associatedtype Value: Equatable & Hashable & Sendable
  typealias Id = Components.Id

  var id: Id { get }
  var name: String { get }
  var unit: Unit { get }

  func validate(_ value: Value) throws
  func isValid(_ value: Value) -> Bool
}

extension Component {

  public var name: String {
    Components.names[id.rawValue]
  }

  public static func `for`(id: String) -> Self {
    guard let component = Components.idMap[id] as? Self else {
      fatalError("Component with id \(id) not found")
    }
    return component
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
