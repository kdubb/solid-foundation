//
//  LinkedComponentContainer.swift
//  SolidFoundation
//
//  Created by Kevin Wooten on 4/30/25.
//


public protocol LinkedComponentContainer: ComponentContainer {
  static var links: [any ComponentLink<Self>] { get }
}

public protocol ComponentLink<Root>: Sendable {
  associatedtype Root: Sendable
  associatedtype Value: Sendable

  var component: any Component<Value> { get }
  func value(in root: Root) -> Value
}

public struct ComponentKeyPathLink<Root, Value>: ComponentLink where Root: Sendable, Value: Sendable {

  private nonisolated(unsafe) let keyPath: KeyPath<Root, Value>

  public init(_ component: some Component<Value>, to keyPath: KeyPath<Root, Value>) where Value: Sendable {
    self.component = component
    self.keyPath = keyPath
  }

  public let component: any Component<Value>

  public func value(in root: Root) -> Self.Value {
    root[keyPath: keyPath]
  }
}


extension LinkedComponentContainer where Self: ComponentContainer {

  public var availableComponentIds: Set<Component.Id> {
    return Set(Self.links.map { $0.component.id })
  }

  public func valueIfPresent<C>(for component: C) -> C.Value? where C: Component {
    guard
      let link = Self.links.first(where: { $0.component.id == component.id })
    else {
      return nil
    }
    return link.value(in: self) as? C.Value
  }

}
