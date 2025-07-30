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
      .map(\.availableComponentKinds)
      .reduce(into: Set()) { $0.formUnion($1) }
      .compactMap { kind in containers.firstNonNil { $0.valueIfPresent(for: kind) }.flatMap { (kind, $0) } }
      .sorted { $0.0 < $1.0 }
      .map { (kind, value) in "\(kind) - \(value)" }
      .joined(separator: "\n")
  }

}

extension CompositeComponentContainer: ComponentContainer {

  public var availableComponentKinds: Set<AnyComponentKind> {
    Set(containers.flatMap(\.availableComponentKinds))
  }

  public func valueIfPresent<K>(for kind: K) -> K.Value? where K: ComponentKind {
    for container in containers {
      if let value = container.valueIfPresent(for: kind) {
        return value
      }
    }
    return nil
  }

}
