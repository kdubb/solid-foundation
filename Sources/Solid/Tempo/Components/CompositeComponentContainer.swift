//
//  CompositeComponentContainer.swift
//  SolidFoundation
//
//  Created by Kevin Wooten on 4/30/25.
//

import Collections

public struct CompositeComponentContainer {

  public let containers: [any ComponentContainer]

  public init(containers: [any ComponentContainer]) {
    self.containers = containers
  }
}


extension CompositeComponentContainer: CustomStringConvertible {

  public var description: String {
    containers
      .map(\.availableComponents)
      .reduce(into: Set()) { $0.formUnion($1) }
      .compactMap { comp in containers.firstNonNil { $0.valueIfPresent(for: comp) }.flatMap { (comp, $0) } }
      .sorted { $0.0 < $1.0 }
      .map { (comp, value) in "\(comp) - \(value)" }
      .joined(separator: "\n")
  }

}

extension CompositeComponentContainer: ComponentContainer {

  public var availableComponents: Set<AnyComponent> {
    Set(containers.flatMap(\.availableComponents))
  }

  public func valueIfPresent<C>(for component: C) -> C.Value? where C: Component {
    for container in containers {
      if let value = container.valueIfPresent(for: component) {
        return value
      }
    }
    return nil
  }

}
