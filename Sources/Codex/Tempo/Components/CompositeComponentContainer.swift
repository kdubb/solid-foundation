//
//  CompositeComponentContainer.swift
//  Codex
//
//  Created by Kevin Wooten on 4/30/25.
//

extension Tempo {

  struct CompositeComponentContainer {

    public let containers: [any ComponentContainer]

    public init(containers: [any ComponentContainer]) {
      self.containers = containers
    }
  }


}

extension Tempo.CompositeComponentContainer: CustomStringConvertible {

  public var description: String {
    var entries: [Tempo.Component.Id: String] = [:]
    for container in containers {
      for componentId in container.availableComponentIds.sorted() {
        guard
          entries[componentId] == nil,
          let value = container.valueIfPresent(for: componentId.component)
        else {
          continue
        }
        entries[componentId] = "- (\(componentId.name)) \(value)"
      }
    }
    return entries.sorted { $0.key < $1.key }.map { $0.value }.joined(separator: "\n")
  }

}

extension Tempo.CompositeComponentContainer: Tempo.ComponentContainer {

  public var availableComponentIds: Set<Tempo.Component.Id> {
    var all = Set<Tempo.Component.Id>()
    for container in containers {
      all.formUnion(container.availableComponentIds)
    }
    return all
  }

  public func valueIfPresent<C>(for component: C) -> C.Value? where C: Tempo.Component {
    for container in containers {
      if let value = container.valueIfPresent(for: component) {
        return value
      }
    }
    return nil
  }

}
